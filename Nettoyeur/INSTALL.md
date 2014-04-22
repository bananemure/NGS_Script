### Set the variable environment for NETTOYEUR:  
`export NETTOYEUR=/path/to/nettoyeur/directory `


**Installing tagcleaner.pl, prinseq-lite.pl, prinseq-graphs.pl**

```
* chmod +x tagcleaner.pl 
* chmod +x prinseq-lite.pl 
* chmod +x prinseq-graphs.pl 
* Create alias with the same names or copy or symlink tagcleaner.pl, prinseq-lite.pl,
  prinseq-graphs.pl to the bin directory.
``` 
**Installing CD-HIT**
Download the latest version from code.google.com/p/cdhit/downloads/list. You can also
use a precompiled version if you like *to install from source, decompress the downloaded
file, cd to the decompressed folder, and issue the following commands: 

```
 make
 sudo make install
```
 
**Installing Blast** 
Download the latest version of Blast+ from
ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ *You can also use a precompiled
version if you like *To install from source, decompress the downloaded file, cd to the
decompressed folder, and issue the following commands: 

```
./configure
 make
 sudo make install
``` 
**Installing Ruby 1.9**

You can use RVM to install ruby:
Download latest certificates (maybe you don’t need them): 

```
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
``` 
**Install SeqtrimNEXT**

SeqtrimNEXT is very easy to install. It is distributed as a ruby gem: 

`gem install seqtrimnext`

This will install seqtrimnext and all the required gems. 

**Install and rebuild SeqtrimNext’s core databases**

SeqtrimNEXT needs some core databases to work. To install them: 

`seqtrimnext -i core`
 
You can change default database location by setting the environment variable BLASTDB.
Refer to [SYNOPSIS][synopis_link] for an example.

There are aditional databases that can be listed with: 

`seqtrimnext -i LIST`

[Bash script to download and configure human database for seqtrimnext][bash_link]
 
**Database modifications**

Included databases will be useful for a lot of people, but if you prefer, you can modify
them, or add more elements to be search against your sequences.
You only need to drop new fasta files to each respective directory, or even create new
directories with new fasta files inside. Each directory with fasta files will be used as a
database:
DB/vectors to add more vectors DB/contaminants to add more contaminants etc…
Once the databases have been modified, you will need to reformat them by issuing the
following command: 

`seqtrimnext -c` 
Modified databases will be rebuilt.
 
**CLUSTERED INSTALLATION** 

To install SeqtrimNEXT into a cluster, you need to have the software available on all
machines. By installing it on a shared location, or installing it on each cluster node. Once
installed, you need to create a init_file where your environment is correctly setup (paths,
BLASTDB, etc): 

```
export PATH=/path/to/blast+/bin:/path/to/cd-hit/bin/
export BLASTDB=/path/to/DB/formatted/
export SEQTRIMNEXT_INIT=path_to_init_file
``` 
And initialize the SEQTRIMNEXT_INIT environment variable on your main node (from
where SeqtrimNEXT will be initially launched): 

`export SEQTRIMNEXT_INIT=path_to_init_file` 
 
SAMPLE INIT FILES FOR CLUSTERED INSTALLATION: Init file 

```
cat stn_init_env 

source ~latex/init_env
source ~ruby19/init_env
source ~blast_plus/init_env
source ~gnuplot/init_env
source ~cdhit/init_env

export BLASTDB=/path/to/DB/formatted/export
SEQTRIMNEXT_INIT=~seqtrimnext/stn_init_env/ 
```

[bash_link]: https://github.com/smbatchou/NGS_Script/blob/master/Nettoyeur/get_homo_sapiensDB.sh
