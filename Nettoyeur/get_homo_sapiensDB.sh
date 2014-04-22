#this bash script will help you download Homo sapiens genome from ncbi.
# please check first online for the current version of sequences because it changes very fast
# ftp://ftp.ncbi.nih.gov/genomes/H_sapiens/Assembled_chromosomes/seq/
# Example hs_ref_GRCh37.p9_chr1.fa.gz could have changed to hs_ref_GRCh37.p10_chr1.fa.gz at the moment you decide to download the DB
#then adjust the correct current version within this script: i.e just replace (p9) by (p10) everywhere if there was actually an update of the version in ncbi.


#create subdirectory
[ ! -d "homo_sapiens" ] && mkdir homo_sapiens;
#goto the directory
[ -d "homo_sapiens" ] && cd homo_sapiens;


#Download sequence data
for i in {1..22} X Y MT; do wget
ftp://ftp.ncbi.nih.gov/genomes/H_sapiens/Assembled_chromosomes/seq/hs_ref_GRCh37.p9_chr$i.fa.gz; done

# Extracting and joining data
for i in {1..22} X Y MT; do gzip -dvc hs_ref_GRCh37.p9_chr$i.fa.gz >>hs_ref_GRCh37_p9.fa;
rm hs_ref_GRCh37.p9_chr$i.fa.gz; done


#splitting sequences by long repeats ambigous base N
cat hs_ref_GRCh37_p9.fa | perl -p -e 's/N\n/N/' | perl -p -e 's/^N+//;s/N+$//;s/N{200,}/\n>split\n/' >hs_ref_GRCh37_p9_split.fa; 
rm hs_ref_GRCh37_p9.fa


#filtering sequences
prinseq-lite.pl -log -verbose -fasta hs_ref_GRCh37_p9_split.fa -min_len 200 -ns_max_p 10
-derep 12345 -out_good hs_ref_GRCh37_p9 -seq_id hs_ref_GRCh37_p9_ -rm_header -out_bad null; 
rm hs_ref_GRCh37_p9_split.fa 
