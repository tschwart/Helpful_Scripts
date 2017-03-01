#!/bin/sh
#
# load the BWA environment
source /opt/asn/etc/asn-bash-profiles-special/modules.sh
module load bwa/0.7.12
module load samtools/1.2
module load gnu_parallel/201612222

#### I recommend you run this with 12 cores (4 cores for each mapping), 16gb

### Change directory to the scratch directory with you cleaned Paired files
#  *** EDIT ***
cd /scratch/aubtss/fastqc_GNU_parallel3  

# Copy the refernece transcriptome to your scratch directory
#  *** EDIT ***
cp /home/aubtss/class_shared/Mini_HeatStress_Data/Garter.Snake.HeatStress.Reference.fa .  

#Indexing reference library for BWA mapping:
        # -p is the prefix
        # -a is the algorithm (is) then the input file
bwa index -p GS_Transcriptome  -a is Garter.Snake.HeatStress.Reference.fa

####  Map paired files with BWA to GarterSnakeReferenceTranscriptome.fa
#### Example
	#bwa mem ref.fa read1.fq read2.fq > aln-pe.sam
	# -t is the number of threads

#### Create list of names to process
# ls (list) contents of directory with files you want to focus on, cut the names of the files at 
        # underscore characters and keep the first three chunks (i.e. fields; -f 1,2,3), 
                        # HS06_GATCAG_All_R1_paired_threads.fastq
                        # HS06_GATCAG_All_R2_paired_threads.fastq
                # 1 = HS06
                # 2 = GATCAG
                # 3 = All  
                # So keep "HS06_GATCAG_ALL"
    	#  Sort the list of names on only keep one of each duplicate     

#### Use that list to run BWA in parallel running as many jobs a possible (-t 6) means to run each job using 6 threads
#  *** EDIT ***
ls | grep "paired_threads.fastq" |cut -d "_" -f 1,2,3 | sort | uniq | time parallel -j+0 --eta bwa mem -t 6 -M GS_Transcriptome {1}_R1_paired_threads.fastq {1}_R2_paired_threads.fastq '>' {1}.sam ::: ${i}
# Output = HS06_GATCAG_All.sam

###############  Using samtools to process the bam Input: HS06_GATCAG_All.sam
#  Make the list of prefixes for all the .sam files we want to process with Samtools
ls | grep "All.sam" |cut -d "_" -f 1,2 | sort | uniq  > list


# Use a loop to process through the names in the list using samtools
while read i;
do
	## convert .sam to .bam and sort the alignments
	# -@ is the number of threads
samtools view -@ 12 -bS ${i}_All.sam  | samtools sort -@ 12 -  ${i}_sorted   # Example Input: HS06_GATCAG_All.sam; Output: HS06_GATCAG_sorted.bam
	## index the sorted .bam
samtools index 	${i}_sorted.bam
	## Tally counts of reads mapped to each transcript; and calcuate the stats. 
samtools idxstats   ${i}_sorted.bam     > 	${i}_Counts.txt
samtools flagstat 	${i}_sorted.bam 	>	${i}_Stats.txt

done<list

##### Make a directory for my results in my home folder
# mkdir /home/YOUR_ID/class_shared/YOUR_NAME/fastqc
#  *** EDIT ***
mkdir /home/aubtss/class_shared/Tonia/BWA_Counts
mkdir /home/aubtss/class_shared/Tonia/BWA_Stats

### Move the results output to my directory for safe keeping
## /home/YOUR_ID/class_shared/YOUR_NAME/fastqc
#  *** EDIT ***
cp *Counts.txt /home/aubtss/class_shared/Tonia/BWA_Counts
cp *Stats.txt /home/aubtss/class_shared/Tonia/BWA_Stats

# Move to your home directory and tarball the folders so they are ready to transfer back to your computer.
#  *** EDIT ***
cd /home/aubtss/class_shared/Tonia
tar cvzf BWA_Counts.tar.gz /home/aubtss/class_shared/Tonia/BWA_Counts
tar cvzf BWA_Stats.tar.gz /home/aubtss/class_shared/Tonia/BWA_Stats
