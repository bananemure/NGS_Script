 
DESCRIPTION: 
NETTOYEUR is a customizable pre-processing software for NGS (Next Generation
Sequencing) biological data. It makes use of -prinseq to generate statistics and quality
data of sequences; - CD-HIT-454 to remove exact or almost exact duplicates sequences; 
-tagcleaner to compute and predict the presence of an adaptor at 5’and to remove the
adaptor when necessary; -seqtrimnext to clean (eliminates low quality regions, remove 3’
adaptor, filter sequences for low size, remove indeterminations, and filter sequences with
contaminants) sequences. It is specially suited for 454/Roche (normal and paired-end)
and Illumina datasets, although it could be easily adapted to any other situation.
 
Necessary resources 
Hardware
  -UNIX based Computer connected to the Internet
Software
  - Up-to-date FIREFOX Web browser 
  - Ruby-1.9.3 minimum: seqtrimnext works with ruby.  
    Do not use the default Linux ruby 1.8. Seqtrimnext does not work fine with this 
    version of ruby.
 - Perl: at least 5.8 version 
Files 
  - FASTA file with sequence data
  - QUAL file with quality scores (if available)
  - FASTQ file (as alternative format)
   
LIST OF PROGRAMS USED BY THE PIPELINE: 

-seqtrimnext: http://rubydoc.info/gems/seqtrimnext/frames 
-prinseq-lite.pl : http://prinseq.sourceforge.net/manual.html 
-prinseq-graph.pl: http://prinseq.sourceforge.net/manual.html 
-tagcleaner.pl: http://tagcleaner.sourceforge.net/manual.html 
-Cd-hit-454: http://weizhong-lab.ucsd.edu/cd-hit/ 
-ncbi blast+: ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ 
-perl dependencies for prinseq-lite and prinseq-graphs: 
You need to install Statistics::PCA and all his dependencies: it is easy to install just
follow the instructions available on: 
http://search.cpan.org/~dsth/Statistics-PCA-0.0.1/lib/Statistics/PCA.pm  
Utility not included in the pipeline but may be useful:  
-fastq2fasta.rb: this utility is necessary to generate fasta and qual file from a fastq file.
It is installed directly along with seqtrimnext and easy to use: 
fastq2fasta.rb input (fastqfile) output (name_of_output) 
Set the variable environment for NETTOYEUR 
export NETTOYEUR=/path/to/nettoyeur/directory 
 
INSTALL: 
Installing tagcleaner.pl, prinseq-lite.pl, prinseq-graphs.pl 
chmod +x tagcleaner.pl 
chmod +x prinseq-lite.pl 
chmod +x prinseq-graphs.pl 
Create alias with the same names or copy or symlink tagcleaner.pl, prinseq-lite.pl,
prinseq-graphs.pl to the bin directory.
 
Installing CD-HIT 
*Download the latest version from code.google.com/p/cdhit/downloads/list *you can also
use a precompiled version if you like *to install from source, decompress the downloaded
file, cd to the decompressed folder, and issue the following commands: 
make
sudo make install
 
Installing Blast 
*Download the latest version of Blast+ from
ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ *You can also use a precompiled
version if you like *To install from source, decompress the downloaded file, cd to the
decompressed folder, and issue the following commands: 
./configure
make
sudo make install
 
Installing Ruby 1.9 
*You can use RVM to install ruby:
Download latest certificates (maybe you don’t need them): 
$ curl -O http://curl.haxx.se/ca/cacert.pem 
$ export CURL_CA_BUNDLE=`pwd`/cacert.pem # add this to your .bashrc or 
equivalent.
Install RVM: 
$ bash < < (curl -k https://rvm.beginrescueend.com/install/rvm) 
Setup environment: 
$ echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
# Load RVM function' >> ~/.bash_profile 
Install ruby 1.9.3 (this can take a while): 
$ rvm install 1.9.3 
Set it as the default: 
$ rvm use 1.9.3 –default
 
Install SeqtrimNEXT 
SeqtrimNEXT is very easy to install. It is distributed as a ruby gem: 
gem install seqtrimnext 
This will install seqtrimnext and all the required gems. 
Install and rebuild SeqtrimNext’s core databases 
SeqtrimNEXT needs some core databases to work. To install them: 
seqtrimnext -i core
 
You can change default database location by setting the environment variable BLASTDB.
Refer to SYNOPSIS for an example.

There are aditional databases that can be listed with: 
seqtrimnext -i LIST
 
Database modifications 
Included databases will be useful for a lot of people, but if you prefer, you can modify
them, or add more elements to be search against your sequences.
You only need to drop new fasta files to each respective directory, or even create new
directories with new fasta files inside. Each directory with fasta files will be used as a
database:
DB/vectors to add more vectors DB/contaminants to add more contaminants etc…
Once the databases have been modified, you will need to reformat them by issuing the
following command: 
seqtrimnext -c 
Modified databases will be rebuilt.
 
CLUSTERED INSTALLATION 
To install SeqtrimNEXT into a cluster, you need to have the software available on all
machines. By installing it on a shared location, or installing it on each cluster node. Once
installed, you need to create a init_file where your environment is correctly setup (paths,
BLASTDB, etc): 
export PATH=/path/to/blast+/bin:/path/to/cd-hit/bin/
export BLASTDB=/path/to/DB/formatted/
export SEQTRIMNEXT_INIT=path_to_init_file
 
And initialize the SEQTRIMNEXT_INIT environment variable on your main node (from
where SeqtrimNEXT will be initially launched): 
export SEQTRIMNEXT_INIT=path_to_init_file 
 
SAMPLE INIT FILES FOR CLUSTERED INSTALLATION: Init file 
$> cat stn_init_env 

source ~latex/init_env
source ~ruby19/init_env
source ~blast_plus/init_env
source ~gnuplot/init_env
source ~cdhit/init_env

export BLASTDB=/path/to/DB/formatted/export
SEQTRIMNEXT_INIT=~seqtrimnext/stn_init_env/ 

 
Bash script to download and configure human database for seqtrimnext  
Copy the followings to a .sh file and do chmod +x. 

#this bash script will help you to download Homo sapiens genome from ncbi.
# please check first online for the current number of sequences because it changes very
fast
# ftp://ftp.ncbi.nih.gov/genomes/H_sapiens/Assembled_chromosomes/seq/
# Example hs_ref_GRCh37.p9_chr1.fa.gz could have changed to hs_ref_GRCh37.p10_chr1.fa.gz
at the moment you decide to download the DB

#then adjust the correct current number within this script: i.e just replace (p9) by
(p10) everywhere if there was actually an update of the number in ncbi.


#create subdirectory
[ ! -d "homo_sapiens" ] && mkdir homo_sapiens;
#goto the directory
[ -d "homo_sapiens" ] && cd homo_sapiens;


#Download sequence data
for i in {1..22} X Y MT; do wget
ftp://ftp.ncbi.nih.gov/genomes/H_sapiens/Assembled_chromosomes/seq/hs_ref_GRCh37.p9_chr$i
.fa.gz; done

# Extracting and joining data
for i in {1..22} X Y MT; do gzip -dvc hs_ref_GRCh37.p9_chr$i.fa.gz >>hs_ref_GRCh37_p9.fa;
rm hs_ref_GRCh37.p9_chr$i.fa.gz; done


#splitting sequences by long repeats ambigous base N
cat hs_ref_GRCh37_p9.fa | perl -p -e 's/N\n/N/' | perl -p -e
's/^N+//;s/N+$//;s/N{200,}/\n>split\n/' >hs_ref_GRCh37_p9_split.fa; rm
hs_ref_GRCh37_p9.fa


#filtering sequences
prinseq-lite.pl -log -verbose -fasta hs_ref_GRCh37_p9_split.fa -min_len 200 -ns_max_p 10
-derep 12345 -out_good hs_ref_GRCh37_p9 -seq_id hs_ref_GRCh37_p9_ -rm_header -out_bad
null; rm hs_ref_GRCh37_p9_split.fa 
 
TEMPLATE FILES
 
seqtrimnext come with some template files where you can configure your cleaning steps:
It is easy to read and customize.
the templates are available at  nettoyeur/templates/ directory
please adjust the database locations in the template files after installation: 

# Path for 454 AB adapters database 
adapters_ab_db = "/path/to/db/formatted/adapters_ab.fasta" ==> change it  
# Path for contaminants database 
contaminants_db = "/path/to/db/formatted/contaminants.fasta" ==> change it  
You can define your own templates using a combination of available plugins: 
PluginLinker
 
PluginAbAdapters 

splits sequences into two inserts when a valid linker is found
(paired-end experiments only) 
 

removes AB adapters from sequences using a predefined DB or
one provided by the user. 
 
PluginAdapters

removes Adapters from sequences using a predefined DB or
one provided by the user. 
 
PluginLowHighSize 
 
PluginIndeterminations 
 
PluginLowQuality 
PluginContaminants 
 
removes sequences too small or too big. 
 
removes indeterminations (N) from the sequence. 
 


eliminates low quality regions from sequences. 



removes contaminants from sequences or rejects contaminated
ones. It uses a core database, but it can be expanded with user
provided ones.
 
You can modify any template to fit your workflow. To do this, you only need to copy one
of the templates and edit it with a text editor, or simply modify a used_params.txt file that
was produced by a previous cleaning step: /output_files/use_params.txt

E.g. If you want to disable repetition removal, do this: 
Copy the template file you wish to customize and name it params.txt. 2-Edit params.txt
with a text editor 3-Find a line like this:
 
remove_clonality = true
 
Replace this line with:
remove_clonality = false 

NOTE: The only mandatory parameter is the plugin_list one. 
SYNOPSIS:
Once installed, NETTOYEUR is very easy to use: 
To install core databases (it should be done at installation time): 
$> seqtrimnext -i core 
Databases will be installed nearby SeqtrimNEXT by default, but you can override this
location by setting the environment variable BLASTDB. Eg.: 
If you with your database installed at /nettoyeur/: 
$> export BLASTDB=/absolute/path/to/nettoyeur/DB/formatted 
Be sure that this environment variable is always loaded before SeqtrimNEXT execution
(Eg.: add it to .bash_profile). 
There are aditional databases. To list them: 
$> seqtrimnext -i LIST 
To perform a cleaning step using a default 454 template with a FASTQ file format: 
$> nettoyeur.pl –platform 454 -fastq input_file_in_FASTQ -clean 
To perform a cleaning using a 454 user predefined template with a FASTQ file format: 
$> nettoyeur.pl -template user_454.txt -fastq input_file_in_FASTQ 
–clean –platform 454 
To clean illumina fastq files with default template: 
$> nettoyeur.pl –platform illumina -fastq input_file_in_FASTQ -clean 
To clean 454 fasta files, with paired-ends and qualities data : 
$> nettoyeur.pl –platform 454 -fasta input_file_in_FASTA –clean –qual
input_file_in_QUAL –paired  
To get additional informations on how to use NETTOYEUR: 
$> nettoyeur.pl –h or nettoyeur.pl --help
$> nettoyeur.pl –man 
 
At the end of all the processes, NETTOYEUR print to STDOUT the list of all executed
command-line applications. So you can reproduce them separately if you want.
 
Contacts: stephabiogen@gmail.com  for debug and feedback. 
