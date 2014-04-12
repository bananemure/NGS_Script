#!/usr/bin/perl

use strict;
use warnings;
#use diagnostics;  #<---- debug

#use Data::Dumper; #<---- debug
use Pod::Usage;
use Getopt::Long;
#use Fcntl qw(:flock SEEK_END); #<-----for log file
use Cwd;
$|=1; # no output buffer

my @cmdseqtrimnext=('seqtrimnext','-R','-K');
my @cmdStatsInitial = qw /prinseq-lite.pl -out_bad null -out_good null -verbose/;
push (@cmdStatsInitial,"-graph_stats","ld,gc,qd,ns,ts,da,dn,"); # -graph_data to add after 
my @cmdStatsFinal = @cmdStatsInitial; #<--- to be used at the end of everything...needs ouput of cleaning as input
my @cmdGraph = qw /prinseq-graphs.pl -html_all/; # -i and -o to add after
my @cmdTagPredict = qw /tagcleaner.pl -predict -matrix exact -64 -verbose/; 
my @cmdTagStats= qw /tagcleaner.pl -stats/;
my @cmdCdhit = qw /cd-hit-454 -aL 0.98 -AL 20 -aS 0.99 -AS 10 -M 0 -T 0 -g 1/; # -i and -o to add at the end
my @cmdTagCleaning= qw/tagcleaner.pl -verbose -64 -matrix exact -out_format 3 -out tmptagcleanerfile/;# -mm5 -fast(a|q) -qual -tag5 to add

my $information= "
@----------------------------------------------------------------------@
|                     NETTOYEUR Stephane Mbatchou 2012                 |
|		      CENTRE DE RECHERCHE ROBERT-CEDERGREN Montreal    |
@----------------------------------------------------------------------@\n";



#===============================================
#  PARAMETRES ET OPTIONS
#===============================================
my $man = 0;
my $help = 0;
my %params = ('help' => \$help, 'h' => \$help, 'man' => \$man);
GetOptions(\%params,
		 'man',
	    'help|h',
       'fastq=s'=>\&checkOptionArg,
       'fasta=s'=>\&checkOptionArg,
       'qual=s'=>\&checkOptionArg,
	    'stats_all',
	    'stats_tag',
	    'tag5=s'=>\&checkOptionArg,
	    'clean',
       'paired',
	    'template=s'=>\&checkOptionArg,
	    'platform=s{1}'=>\&checkOptionArg,
	    'outdir=s'=>\&checkOptionArg,
	    'out=s'=>\&checkOptionArg) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

=head1 NAME

NETTOYEUR - Preprocessing and Quality Information of Sequence data

=head1 VERSION

NETTOYEUR

=head1 SYNOPSIS

perl nettoyeur.pl [-h] [-help] [-fasta input_fasta_file] [-qual input_qual_file] [-fastq input_fastq_file] 
[-clean] [-platform 454_or_illumina] [-stats_all] [-stats_tag] [-tag5 string_sequence] [-template user_defined_templates_file]
[-out string_name_output] [-outdir string_output_directory] [-paired]

=head1 DESCRIPTION

NETTOYEUR will help you to preprocess your genomic or metagenomic sequence data in FASTA (and QUAL) or FASTQ format. This version requires prinseq-lite.pl
prinseq-graphs.pl tagcleaner.pl seqtrimnext and cd-hit-454 for processing.

=head1 OPTIONS

=over 8

=item B<-help> | B<-h>

print the help message.

=item B<======*INPUT OPTIONS*======>


=item B<-fastq> <file>

Input file in FASTQ format that contains the sequence and quality data. required if FASTA and QUAL are not specified.

=item B<-fasta> <file>

Input file in FASTA format that contains the sequence and quality data. is used in combination with QUAL quality data.

=item B<-qual> <file>

Input file in QUAL format that contains the quality data. Can only be used when FASTA file is specified. 
Not to be used with a FASTQ file.

=item B<-template> <file>

Input text file that contains the informations and configuration parameters to be used by the program for all the cleaning steps.
This option should be set by the user. when -template is specified the program will use this template instead of the default templates.

=item B<======*OUTPUT OPTIONS*======>


=item B<-out> <string>

By default, the output files are created in the directory "output_files" containing the sequence data with an additional "_clean" in their name.
To change the output filename, specify the filename using this option. The file extension will be added automatically.

Example: use "file_filtered" to generate the output file file_filtered.fastq in the "output_files" directory

=item B<-outdir> <string>

By specifying this option the actual output directory will change to the specified one.
if option "-out" is also specified the name will also be modified. See option "-out" for more informations.


=item B<======*PROCESSING OPTIONS*======>


=item B<-stats_tag>

This option will compute and predict the presence of an adaptor at 5' if possible. The result is display on STDOUT.

=item B<-stats_all>

outputs all available statistics for the input sequence. The results will be displayed on a webpage.

=item B<-clean>

will remove adaptor(5'3') if present, check and remove exact and nearly exact duplications (454), remove indeterminations (Ns), 
check and discard sequence with contaminants when found, remove low quality segment, discard very short sequences. 
this option requires to specify the platform and/or the user template.

=item B<-platform><454 or illumina>

indicates the type of platform where the sequences come from. It is used in combination with -clean.

=item B<-paired>

indicates whether the input sequences should be considered as paired-end during cleaning steps. 
This option is only used when -platform is set to 454. It's not suited for illumina.

=item B<-tag5> <string>

indicates the sequence of 5'adaptor to be considered for cleaning steps. 

=item B<> <default option>

when only the input files and -platform are specified the program will consider a default option and will
execute all the steps ( initial statistics + cleaning + final statistics).

=back

=head1 AUTHOR

Stephane Mbatchou, C<< <stephabiogen_at_gmail_dot_com> >>

=head1 BUGS

If you find a bug please email me at C<< <stephabiogen_at_gmail_dot_com> >> .

=head1 COPYRIGHT

Copyright (C) 2012  Centre de recherche robert cerdergren

=head1 LICENSE

This program is free software: you can redistribute it and/or modify as you need.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut


#==============================================
#	GESTION DES PARAMETRES INPUT OUPUT
#==============================================

#Check if input file exists and check if file format is correct
my $file1;
if(exists $params{fasta} && exists $params{fastq}) {
    &printError('fasta and fastq cannot be used together');
} elsif(exists $params{fasta}) {                          	
    push (@cmdseqtrimnext,'-f',$params{fasta});		   #<-------	
    push (@cmdStatsInitial, '-fasta',$params{fasta});      #<-------	
    push (@cmdTagPredict,'-fasta',$params{fasta});         #<-------
    push (@cmdTagStats,'-fasta',$params{fasta});  	   #<-------
    push (@cmdTagCleaning,'-fasta',$params{fasta});	   #<-------
    $file1 = $params{fasta};                
     if(-e $params{fasta}) {
        #check for file format
        my $format = &checkFileFormat($file1);
        unless($format eq 'fasta') {
            &printError('input file for -fasta is in '.uc($format).' format not in FASTA format');
        }
    } else {
        &printError("could not find input file \"".$params{fasta}."\"");
    }
} elsif(exists $params{fastq}) {
    push (@cmdseqtrimnext,'-Q',$params{fastq});		   #<-------	
    push (@cmdStatsInitial, '-fastq',$params{fastq});      #<-------	
    push (@cmdTagPredict,'-fastq',$params{fastq});         #<-------
    push (@cmdTagStats,'-fastq',$params{fastq});  	   #<-------
    push (@cmdTagCleaning,'-fastq',$params{fastq});	   #<-------
    $file1 = $params{fastq};
    
    if(-e $params{fastq}) {
        #check for file format
        my $format = &checkFileFormat($file1);
        unless($format eq 'fastq') {
            &printError('input file for -fastq is in '.uc($format).' format not in FASTQ format');
        }
    } else {
        &printError("could not find input file \"".$params{fastq}."\"");
    }
} else {
    &printError("you did not specify an input file containing the query sequences");
}
if(exists $params{fastq} && exists $params{qual}) {
    &printError('fastq and qual cannot be used together');
} elsif(exists $params{qual}) {
    push (@cmdseqtrimnext,'-q',$params{qual});		   #<-------	
    push (@cmdStatsInitial, '-qual',$params{qual});        #<-------	
    push (@cmdTagCleaning,'-qual',$params{qual});	   #<-------
     if(-e $params{qual}) {
        #check for file format
        my $format = &checkFileFormat($params{qual});
        unless($format eq 'qual') {
            &printError('input file for -qual is in '.uc($format).' format not in QUAL format');
        }
    } else {
        &printError("could not find input file \"".$params{qual}."\"");
    }
}
#check for tag5 arguments
if (exists $params{tag5} and !(&checkTag($params{tag5}))){
   &printError("The tag sequence: ".uc($params{tag5})." is not in valid format[ACGTN]");
}elsif (exists $params{tag5} and (&checkTag($params{tag5})) and (length($params{tag5})<4)){
   &printError("The tag sequence:" .uc($params{tag5})." is too short[min:4 max:64]");
}

#check for the platform arguments
my $platform;
if (exists $params{platform}){
	if ($params{platform} eq '454'){
		$platform=$params{platform};
		if (exists $params{paired}){
		   push (@cmdseqtrimnext,'--template', $ENV{NETTOYEUR}."/templates/454paired.txt") unless exists $params{template};#<----- a verifier apres installation
		}else{
		   push (@cmdseqtrimnext,'--template', $ENV{NETTOYEUR}."/templates/454only.txt") unless exists $params{template};	#<----- a verifier apres installation
		}

	}elsif ($params{platform} eq 'illumina'){
	       $platform=$params{platform};
		#if (exists $params{paired}){
		   #push (@cmdseqtrimnext,'--template', cwd()."/templates/illumina_paired.txt") unless !exists $params{clean};#<------ a verifier apres installation
		#}else{
		   push (@cmdseqtrimnext,'--template', $ENV{NETTOYEUR}."/templates/illumina.txt") unless exists $params{template};#<----- a verifier apres installation	
		#}
		
	}else{
		&printError("Unknown platform format \'$params{platform}\': platform arguments must be either \'454 or illumina\'");
	}
} 

#check for template specified by user

if(exists $params{template}){
	push (@cmdseqtrimnext,'--template',$params{template}) unless !(-e $params{template});				 #<----------	
	&printError("The template file: "."\'".$params{template}."\'"." cannot be found") unless (-e $params{template});
	print STDERR "\nERROR: The format of this template \'$params{template}\' is not correct. 
	Please check the line 'plugin_list' of your template.
	\nExit Program.\n\n" unless &checkTemplateFile($params{template});
	exit(0) unless &checkTemplateFile($params{template});
}

#check if anything to do with input data 

unless (exists $params{stats_all}||
	 exists $params{clean}||   # important 
	 exists $params{stats_tag}||
	 exists $params {platform}) {
	&printError("nothing to do with input data, some Options are required.\nOption\'-stats_all\': if you want to generate only statistics\n
Option\'-stats_tag\': if you want to generate only statistic for 5\'adaptor\n
or Option\'-clean together with option -platform\': if you want to do only the cleaning\n
or Option \'platform\' only if you want to do all the steps==>statistics+cleaning");
}

#check for conflicting options
&printError("The option '-clean' requires option '-platform'") if (exists $params{clean} && !defined($platform));
&printWarning("The option '-stats_all' is already included when option '-platform' is called") if (exists $params{stats_all} && (exists $params{platform}));
&printWarning("The option '-stats_tag' is already included when option '-platform' is called") if (exists $params{stats_tag} && (exists $params{platform}));

if ((exists $params {paired}) && !(exists $params{clean})){
   &printError("The option '-paired' can only be used when '-clean' and/or '-platform' are required") unless (defined($platform));	
}

&printError("The option '-clean' requires quality file at option '-qual'") if ((exists $params{clean}) && !(exists $params{qual})&& !(exists $params{fastq}));# fasta is ok

my $optionstats=0;
if (exists $params{stats_all} && exists $params {stats_tag}){
	#stats_all is beyond stats_tag no need to execute stats_tag
	 $optionstats=1;
}elsif (!exists $params{stats_all} && exists $params{stats_tag}){
	$optionstats=2;
}elsif (!exists $params{stats_tag} && exists $params{stats_all}){
	$optionstats=3;
}



#==================================================================================
#after all verifications===>then execution
#==================================================================================
	 
my $welcome = "\tBienvenue au nettoyage de vos séquences";
my $separationLigne ="\n==================================================================================\n\n";

		#theses are required by prinseq and prinseq-graphs.
my $htmldir=cwd()."/html_stats";
if (exists $params{stats_all}){
	system('rm','-rf',$htmldir) if (-e $htmldir);
	mkdir($htmldir,0777) or die ("\tFatal error: Creation of $htmldir is impossible:$!.
\tPlease check your right or use another permissible directory\n\nExit Program\n\n") if !(-e $htmldir);
}
my $graphInitial = $htmldir."/graphInitial.gd";
my $graphFinal =$htmldir."/graphFinal.gd";
my $htmlInitial = $htmldir."/initialStatistics";
my $htmlFinal = $htmldir."/finalStatistics";

		#the followings are required to rename outputfile	
my $inputfinal=cwd()."/output_files/sequences_.fastq";
my $inputname = &parseName($file1);
my $outputdir;
my $outputname = $inputname; 
$outputname =~ s/\.fast[aq]/_clean.fastq/;
my $outputfinal = cwd()."/output_files/".$outputname;
if (exists $params{outdir}){
   $outputdir=$params{outdir}; 							#<-----user defied output directory/filename
   mkdir($params{outdir},0777) or die ("\tFatal error: Creation of ".$params{outdir}." is impossible:$!.
\tPlease check your right or use default output directory\n\nExit Program\n\n") if !(-e $params{outdir});
   if (!exists $params{out}){
      $outputfinal= $outputdir."/".$outputname;
   }else{
      $outputfinal=$outputdir."/".$params{out}.".fastq"; 
   }
}elsif (exists $params{out}){
   $outputfinal = cwd()."/output_files/".$params{out}."fastq";
}
	
my $mm5;  										#<---- FOR tag5 MISMATCHES ...see tagPredictor() sub
my $tag5;  										#<----recuperation of tag5 sequence; 

		#	MESSAGE D'ACCUEIL
print "$information\n\tDebut du programme\n"."$welcome\n\n";


#=========================> all EXECUTIONS steps:start here<===========================
my @allcmd;	
my $errorfile = &newErrorFile();

&statsExec($file1,$graphInitial,$htmlInitial,\@cmdStatsInitial) if (exists $params{stats_all} || $optionstats==1) ;
&tagPredictor($file1) if ((exists $params{stats_all}) || (exists $params{stats_tag}));
 

#***********: starting from now order of executions here is very important.do not change the order(***)********
		
#   ====> execution for -clean<=====
if (exists $params{clean}){
	# stats 5' for -clean
	if (!exists $params{tag5}){ 
   	$tag5= &tagPredictor($file1);
   	push (@cmdTagStats,'-tag5',$tag5) if ($tag5);	#<-----
   	$mm5 = &tagStats($tag5) if ($tag5);
	}elsif (exists $params{tag5}){
   	$tag5= $params{tag5};
   	push (@cmdTagStats,'-tag5',$tag5);			#<----- $tag5 passed the control already 
   	$mm5 = &tagStats($tag5) ;
	}
	# cleaning for -clean
	if (!defined($mm5)){  #<----- no tag indentified and no -tag option was specified
   	print "\tWARNINGS: No 5'ADAPTOR CLEANING IS CONSIDERED FOR THE NEXT STEPS\n\n"; 
   	&cleaning($file1); #<----- seqtrimnext
   	if (defined($platform) && ($platform eq '454')){
   		push (@cmdCdhit,'-i',$inputfinal,'-o',$outputfinal);		#<-------
   		&cdhit454() ;
   		exit if system('rm','-rf',$inputfinal)!=0;

  		}elsif (defined($platform) && ($platform eq 'illumina')){
         die("\nFatal Error: Generation of $outputfinal failed:") if system('mv',$inputfinal,$outputfinal)!=0;    		
   	}
   	
	}elsif (defined($mm5)){  #<----- tag is specified by user or is predicted
   	&tagCleaning($mm5,$tag5);
   	$cmdseqtrimnext[4]= 'tmptagcleanerfile.fastq';   #<----seqtrim will use the output of tagcleaner (5'tag cleaning)
   	&cleaning($file1); #<----- seqtrimnext
   	if (defined($platform) && ($platform eq '454')){
       	push (@cmdCdhit,'-i',$inputfinal,'-o',$outputfinal);
    		&cdhit454() ;
   		exit if system('rm','-rf',$inputfinal)!=0;

   	}elsif (defined($platform) && ($platform eq 'illumina')){
       	die("\nFatal Error: Generation of $outputfinal failed:") if system('mv','-f',$inputfinal,$outputfinal)!=0;
   	}
	}
}
#======> end of execution for -clean<=====================

#======> Starting of execution for Default : cleaning + statistics (-platform alone)<==========

elsif (exists $params{platform} && !exists $params{clean}){

	&statsExec($file1,$graphInitial,$htmlInitial,\@cmdStatsInitial); 
	# stats 5' for -default
	if (!exists $params{tag5}){ 
   	$tag5= &tagPredictor($file1);
   	push (@cmdTagStats,'-tag5',$tag5) if ($tag5);	#<-----
   	$mm5 = &tagStats($tag5) if ($tag5);
	}elsif (exists $params{tag5}){
   	$tag5= $params{tag5};
   	push (@cmdTagStats,'-tag5',$tag5);			#<----- $tag5 passed the control already 
   	$mm5 = &tagStats($tag5) ;
	}
	# cleaning for -default
	if (!defined($mm5)){  #<----- no tag indentified and no -tag option was specified
   	print "\tWARNINGS: No 5'ADAPTOR CLEANING IS CONSIDERED FOR THE NEXT STEPS\n\n"; 
   	&cleaning($file1); #<----- seqtrimnext
   	if (defined($platform) && ($platform eq '454')){
   		push (@cmdCdhit,'-i',$inputfinal,'-o',$outputfinal);		#<-------
   		&cdhit454() ;
   		push (@cmdStatsFinal,'-fastq',$outputfinal);  			#<--------
   		exit if system('rm','-rf',$inputfinal)!=0;

  		}elsif (defined($platform) && ($platform eq 'illumina')){
        die("\nFatal Error: Generation of $outputfinal failed:") if system('mv','-f',$inputfinal,$outputfinal)!=0;
        push (@cmdStatsFinal,'-fastq',$outputfinal);   		#<---------
   	}

   &statsExec($file1,$graphFinal,$htmlFinal,\@cmdStatsFinal) ; #<---il faut juste traiter @cmdStatsFinal d'abord

	}elsif (defined($mm5)){  #<----- tag is specified by user or is predicted
   	&tagCleaning($mm5,$tag5);
   	$cmdseqtrimnext[4]= 'tmptagcleanerfile.fastq';   #<----seqtrim will use the output of tagcleaner (5'tag cleaning)
   	&cleaning($file1); #<----- seqtrimnext
   	if (defined($platform) && ($platform eq '454')){
       	push (@cmdCdhit,'-i',$inputfinal,'-o',$outputfinal);
    		&cdhit454() ;
   		push (@cmdStatsFinal,'-fastq',$outputfinal);
   		exit if system('rm','-rf',$inputfinal)!=0;

   	}elsif (defined($platform) && ($platform eq 'illumina')){
       	die("\nFatal Error: Generation of $outputfinal failed:") if system('mv','-f',$inputfinal,$outputfinal)!=0;
       	push (@cmdStatsFinal,'-fastq',$outputfinal);
   	}

   &statsExec($file1,$graphFinal,$htmlFinal,\@cmdStatsFinal) ; #<---il faut juste traiter @cmdStatsFinal d'abord
	}
}


#=================================> ********** end of  EXECUTIONS *********<=================================================================


#===============================================
#  FUNCTIONS UTILES
#===============================================

sub cleaning{
    my $file1=shift;
    my @outputfilesToRemove;
    my @removable = qw(scbi_mapreduce_checkpoint old_scbi_mapreduce_checkpoint cd-hit-454.out graphs clusters.fasta clusters.fasta.clstr output_files/initial_stats.json);
    foreach my $elt(@removable){ # this step is VERY IMPORTANT for seqtrimnext and cd-hit-454
	 print STDERR "...deleting $elt if there is an old file\n";
	 system('rm','-rf',$elt) if (-e $elt);
    }
    print "\n\t*** CLEANING IS STARTED for $file1 ***\n\n";
    system("@cmdseqtrimnext 2>$errorfile")==0 or &errorControl($errorfile) or die "ERROR CANNOT execute seqtrimnext Program is stopped\n\n";
    push(@allcmd,\@cmdseqtrimnext);
    print "\tSEQTRIMNEXT done\n\n...Deleting tmp files generated by tagcleaner\n\n";
    system('rm','-rf','tmptagcleanerfile.fastq') if (-e 'tmptagcleanerfile.fastq');
}

sub tagCleaning{ #<---requires the result of tagStats:<$mm5>: as args
    my ($mm5,$tag5)=@_;
    push (@cmdTagCleaning,'-mm5',$mm5,'-tag5',$tag5);
    print "\tINFO:--Cleaning of 5'adaptor...\n";
    &execute('tagcleaner',@cmdTagCleaning);	push(@allcmd,\@cmdTagCleaning);
    print "\t5\'ADAPTOR REMOVED\n\n"; 
}

sub tagPredictor {
    my $file1=shift;
    my $tag5pred;
    print "\tINFO:--Computing TAG5 Prediction for $file1\n";
    print "\n@cmdTagPredict\n";
    push (@allcmd, \@cmdTagPredict);

    open (PS,"@cmdTagPredict |") or die "Prediction Error:$!";
    while (my $line=<PS>){
	 chomp($line);
	 if ($line =~ m/(Error|error|ERROR)/){
	 	print STDERR "\nFatalError: The following external error will stop the program:\n\n\n$line\nProgram Halted\n\n";
   	exit(0);
	 }
	 my @line= split(' ',$line); 
	 if (my $howmany= grep(/tag5/, @line)){
		$tag5pred=$line[1];
		$tag5pred =~s/N//g;
		print "\t$line\n";
	 }
	#print $line;
    }
    close(PS);

    if ($tag5pred) {
	print "\n";
	print"\tPREDICTION SUCCESS\tTAG5===> $tag5pred\n\n";
       return $tag5pred;
    }else { 
	print STDERR "\t\nthe presence of tag5 cannot be predicted: ** Make sure that the 5'adaptor is not already removed.
Otherwise you need to provide the tag5 sequence at option '-tag5' **\n\n";
       return 0;
    }   	
}

sub tagStats{    #compute tag5 statistics <---required $tag5 as args
    my $mm5=0;   #<----important...need to be different of UNDEF
    my $tag5=shift;
    print "\tINFO:--Computing of TAG5 statistics\n";
    print"\n@cmdTagStats\n"; push (@allcmd,\@cmdTagStats);
    open (PS, "@cmdTagStats |") or die "Fatal error:$!";
    while (my $lines=<PS>){
	 chomp($lines);
	 if ($lines =~ m/(Error|error|ERROR)/){
	 	print STDERR "\nFatalError: The following external error will stop the program:\n\n\n$lines\nProgram Halted\n\n";
   	exit(0);
	 }
	 my @lines= split(' ',$lines); 
	 if (my $howmany= grep(/100\.00$/, @lines)){
		$mm5=int($lines[1]);
		print "\tmaximum found $tag5 MISMATCHES => $mm5\n";
	}
	#print "$lines\n";
    }
    close(PS);
    print "\ttag statistics done\n\n";
    return $mm5; #<--- number of mismatches max (GLOBAL VARIABLE)	
}

sub statsExec{
    my ($file1,$graph,$htmlfile,$cmdStats)=@_;
    my $affichageStats="firefox $htmlfile.html &";
    my @affichageStats = ($affichageStats);
    print "\tINFO:--Computing statistics for $file1\n";
    push (@$cmdStats,'-graph_data', $graph);
    &execute('prinseq',@$cmdStats); push (@allcmd, \@$cmdStats); 
    push (@cmdGraph,'-i',$graph,'-o',$htmlfile);
    &execute('prinseq-graph', @cmdGraph); push(@allcmd, \@cmdGraph);
    print "\n@affichageStats\n";
    system("$affichageStats 2>$errorfile"); push(@allcmd,\@affichageStats);
    &errorControl($errorfile);
    &testlaunch('firefox');
}

sub cdhit454 {
    my @toRemoveFirst= qw/cd-hit-454.out clusters.fasta clusters.fasta.clstr/;
    foreach my $elt (@toRemoveFirst){
        system('rm','-rf',$elt) if (-e $elt);
    }
    print "\tINFO:--Removing newly generated duplications\n";
    &execute('cd-hit-454',@cmdCdhit); push (@allcmd,\@cmdCdhit);
    print "\tRemoval of new duplications done\n\n"	;
}

sub parseName{
    my $file = shift;	
    my @file = split('/',$file);
    return $file[-1];	
}
sub testlaunch{
	my $software = uc(shift);
	if ($? != -1){print "\n\t$software done\n\n";} 
	else {print "\nFatal Error: Execution of $software failed\n\nExit program\n";exit(0)}
}

sub printError {
    my $msg = shift;
    print STDERR "\nERROR: ".$msg.".\n\nTry \'perl nettoyeur.pl -h\' for more information.\nExit program.\n";
    exit(0);
}
sub printWarning {
    my $msg = shift;
    print STDERR "\nWARNING: ".$msg.".\n";
}


sub checkOptionArg{					#<-----only for option with string arguments
		my ($option,$args)=@_;
		print STDERR "Option \'-$option\' requires a valid argument. Prefix \"-\" is not allowed for argument.\n\nExit program\n\n" if $args=~ m/^\-/;
		exit(0) if $args=~ m/^\-/;
		$params{$option}=$args if $args!~ m/^\-/;
}


sub checkFileFormat {
    my $file = shift;
    my ($format,$count,$id,$fasta,$fastq,$qual);
    $count = 3;
    $fasta = $fastq = $qual = 0;
    $format = 'unknown';

    open(FILE,"perl -pe 's/\r\n|\r/\n/g' < $file |") or die "ERROR: Could not open file $file: $! \n"; #<---pb compatibility windows to unix 
    while (<FILE>) {
#        chomp();
 #       next unless(length($_));
        if($count-- == 0) {
            last;
        } elsif(!$fasta && /^\>\S+\s*/o) {
            $fasta = 1;
            $qual = 1;
        } elsif($fasta == 1 && (/^[ACGTURYKMSWBDHVNXacgturykmswbdhvnx-]+/o)) {
            $fasta = 2;
        } elsif($qual == 1 && /^\s*\d+/o) {
            $qual = 2;
        } elsif(!$fastq && /^\@(\S+)\s*/o) {
            $id = $1;
            $fastq = 1;
        } elsif($fastq == 1 && (/^[ACGTURYKMSWBDHVNXacgturykmswbdhvnx-]+/o)) {
            $fastq = 2;
        } elsif($fastq == 2 && /^\+(\S*)\s*/o) {
            $fastq = 3 if($id eq $1 || /^\+\s*$/o);
        }
    }
    close(FILE);
    if($fasta == 2) {
        $format = 'fasta';
    } elsif($qual == 2) {
        $format = 'qual';
    } elsif($fastq == 3) {
        $format = 'fastq';
    }

    return $format;
}

sub checkTag {
	my $tag = shift;
	$tag = uc($tag);
	if($tag =~ m/^[ACGTN]+$/) {
		return 1;
	} else {
		return 0;
	}
}

sub checkTemplateFile {     # this sub return a reference to a %hash with option and values of template files 
    my $file= shift;
    my @args;
    my %parameters = ();
    open(FILE,"perl -pe 's/\r\n|\r/\n/g' < $file |") or die "ERROR: Could not open Template file $file: $! \n"; #<---pb compatibility windows to unix
    while(<FILE>) {
        next if(/^\#|mids|^adapters_ab|^next_gen|^all_fo|^contaminants_|^sequencing|^generate_|max_seq|accept_very/);
        chomp();
        @args = split(/\s*=\s*/); #<------------- ok
        if(@args) {
            $args[0] =~ s/^\-//;
            $parameters{$args[0]} = (defined $args[1] ? join(" ",@args[1..scalar(@args)-1]) : '');# à revoir mais ok
        }
    }
    close(FILE);
    return \%parameters if defined $parameters{'plugin_list'};											#<-------
    return 0 if !defined $parameters{'plugin_list'};														#<-------
}

sub showTemplateFile {  # this sub display the option and values from reference of %hash from readTemplateFile
     my $parameters = shift;
     while ( my ($key, $value) = each(%$parameters) ) {
        print "$key => $value\n";
     }	
}
sub errorControl{
	my $errorfile=shift;
	my $errmess;
	open (ERR,"< $errorfile") or die ("\nFatalError: Cannot open $errorfile to check for external program error: $!"); #if (-e $errorfile && !-z $errorfile);
	if (!-z $errorfile) {
		while (my $errline=<ERR>){
			chomp($errline);
			#next unless $errline !~ m/^Warning:/;
			next unless $errline =~ m/(Error|error|ERROR|Failed)/;
			$errline= "SEQTRIMNEXT could not generate correct input files for CD-HIT " if $errline eq "Failed to open the database file";
			$errmess.=$errline."\n"; 			
   	}
   }
   close(ERR);
   if (defined($errmess)){
   	#open (REP,">$errorfile");
   	print STDERR "\nFatalError: The following external error will stop the program:\n\n\n$errmess\nProgram Halted\n\n";
   	exit(0);
   }
   #close (REP);	
}

sub newErrorFile {
	my $errorfile=cwd()."/program.stderr";
	open FERR,">$errorfile" or die ("Cannot open $errorfile to check for error:$!");
	print FERR ""; 
	close(FERR);
	return $errorfile if (-e $errorfile);
}

sub execute{
	my($name,@cmdToExecute)=@_;
	$name=uc($name);
	print "\n$name\n\n";
	print "@cmdToExecute\n\n";
	open (PS, "@cmdToExecute 1>&2|") or die "Fatal error:$!";
   while (my $lines=<PS>){
	 	chomp($lines);
	 	if ($lines =~ m/(Error|error|ERROR|Failed)/){
	 		print STDERR "\nFatalError: The following external error will stop the program:\n\n\n$lines\nProgram Halted\n\n";
   		exit(0);
	 	}
	}
   close(PS);
   print "\t$name done\n\n";
}

#===============================================
#	MESSAGE DE FIN
#===============================================
print $separationLigne;
print "\tList of executed commands: \n\n";
foreach my $elt(@allcmd){
	print "=> @$elt\n\n";
}
print "\tFin de l'essai\n"; exit;
