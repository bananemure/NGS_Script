## NETTOYEUR version1.0 (September 2012)
 
### DESCRIPTION:

**NETTOYEUR** is a customizable pre-processing software for NGS (Next Generation
Sequencing) biological data. It makes use of 
- [prinseq][prinseq] to generate statistics and quality data of sequences; 
- [CD-HIT-454][cdhit] to remove exact or almost exact duplicates sequences; 
- [tagcleaner][tagcleaner] to compute and predict the presence of an adaptor at 5’and to remove the
adaptor when necessary; 
- [seqtrimnext][seqtrimnext] to clean (eliminates low quality regions, remove 3’
adaptor, filter sequences for low size, remove undeterminations, and filter sequences with
contaminants) sequences. It is specially suited for 454/Roche (normal and paired-end)
and Illumina datasets, although it might be easily adapted to any other situation.
 
Necessary resources 
Hardware
  - UNIX based Computer connected to the Internet
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
 
   
### LIST OF PROGRAMS USED BY THE PIPELINE:

- seqtrimnext: http://rubydoc.info/gems/seqtrimnext/frames 
- prinseq-lite.pl : http://prinseq.sourceforge.net/manual.html 
- prinseq-graph.pl: http://prinseq.sourceforge.net/manual.html 
- tagcleaner.pl: http://tagcleaner.sourceforge.net/manual.html 
- Cd-hit-454: http://weizhong-lab.ucsd.edu/cd-hit/ 
- ncbi blast+: ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ 
- perl dependencies for prinseq-lite and prinseq-graphs: You need to install Statistics::PCA and all his dependencies:    it is easy to install just
  follow the instructions available on: http://search.cpan.org/~dsth/Statistics-PCA-0.0.1/lib/Statistics/PCA.pm  

Utility not included in the pipeline but may be useful:  
- fastq2fasta.rb: this utility is necessary to generate fasta and qual file from a fastq file. It is installed directly   along with seqtrimnext and easy to use: 
 fastq2fasta.rb input (fastqfile) output (name_of_output) 


### INSTALL:<br/> 
see [HOW TO INSTALL][install]

### CONFIGURATION: <br/>
NETTOYEUR come with some template files where you can configure your cleaning steps:
<br/>
see [CONFIGURATION][configuration]

 
#### NOTE: 
>Once installed, NETTOYEUR is very easy to use: see [SYNOPSIS][synopsis]:

Contacts: stephabiogen@gmail.com  for debug and feedback. 

[install]: https://github.com/smbatchou/NGS_Script/edit/master/Nettoyeur/INSTALL.md
[configuration]: https://github.com/smbatchou/NGS_Script/edit/master/Nettoyeur/CONFIGURATION.md
[synopsis]: https://github.com/smbatchou/NGS_Script/edit/master/Nettoyeur/SYNOPSIS.md
[prinseq]: http://prinseq.sourceforge.net
[cdhit]: http://weizhong-lab.ucsd.edu/cd-hit/
[tagcleaner]: http://tagcleaner.sourceforge.net
[seqtrimnext]: http://rubydoc.info/gems/seqtrimnext

