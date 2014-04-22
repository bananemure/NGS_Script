
#### To perform a cleaning step using a default 454 template with a FASTQ file format: 

`nettoyeur.pl –platform 454 -fastq input_file_in_FASTQ -clean `

#### To perform a cleaning using a 454 user predefined template with a FASTQ file format: 

`nettoyeur.pl -template user_454.txt -fastq input_file_in_FASTQ –clean –platform 454 `

#### To clean illumina fastq files with default template: 

`nettoyeur.pl –platform illumina -fastq input_file_in_FASTQ -clean `

#### To clean 454 fasta files, with paired-ends and qualities data: 

`nettoyeur.pl –platform 454 -fasta input_file_in_FASTA –clean –qual input_file_in_QUAL –paired  `

#### To get additional informations on how to use NETTOYEUR: 

```perl
nettoyeur.pl –h or nettoyeur.pl --help
nettoyeur.pl –man 
``` 

>**At the end of all the processes, NETTOYEUR print to STDOUT the list of all executed
command-line applications. So you can reproduce them separately if you want.**

