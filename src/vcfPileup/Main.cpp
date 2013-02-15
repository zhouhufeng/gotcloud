#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <math.h>
#include <string>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <vector>
#include <map>

#include "SamFile.h"
#include "PileupWithoutGenomeReference.h"
#include "PileupElementBaseQual.h"
#include "tclap/CmdLine.h"
#include "tclap/Arg.h"
#include "InputFile.h"

int main(int argc, char ** argv)
{			    
	try 
	{
		std::string desc = "Example:\n\
./gpileup -r /data/local/ref/karma.ref/human.g1k.v37 -b ../data/HG00160.chrom20.ILLUMINA.bwa.GBR.low_coverage.20100517.bam -v HG00160.chrom20.ILLUMINA.bwa.GBR.low_coverage.20100517.vcf -i -i ../data/LDL_b37.modified.genos.EUR.vcf -d \n\
Pileup takes in a BAM file and a genome reference file to return the following \n\
Alignment statistics are written to the VCF file specified, if the file name ends with .gz, the file output will be in gzip format.\n\
1. CHROM   : chromosome.\n\
2. POS     : position on chromosome.\n\
3. ID      : id.\n\
4. REF     : Reference base in the reference genome. A,C,T,G,N.\n\
5. ALT     : alt.\n\
6. QUAL    : quality score. \n\
7. FILTER  : filter.\n\
8. INFO    : info.\n\
9. FORMAT  : headers of custom data.\n\
   a. N         : number of contigs mapped at this locus.\n\
   b. BASE      : bases of respective contigs, '-' for deletions.\n\
   c. MAPQ      : quality score of the mapping for the contig, this is also shown for deletions.\n\
   d. BASEQ     : phred quality score, -1 for deletions.\n\
   e. STRAND    : F - forward, R - reverse.\n\
   f. CYCLE     : sequencing cycle, -1 for deletions.\n\
   g. GL        : genotype likelihood scores - AA,AC,AG,AT,CC,CG,CT,GG,GT,TT.\n\
10. <vcf output file name> : contains data described in FORMAT.\n";
   			
   		std::string version = "0.577";
		TCLAP::CmdLine cmd(desc, ' ', version);
		TCLAP::ValueArg<std::string> argInputBAMFileName("b", "bam", "BAM file", true, "", "string");
		//TCLAP::ValueArg<std::string> argRefSeqFileName("r", "reference", "Reference Sequence file", true, "", "string");
		TCLAP::ValueArg<std::string> argInputVCFFileName("i", "inputvcf", "VCF file listing the loci of interest (can be gzipped), bam index file is automatically assumed to be in the same location as the bam file.", false, "", "string");
		TCLAP::ValueArg<std::string> argOutputVCFFileName("v", "outputvcf", "VCF file - if the extension is .gz, the written file will be a gzip file, (default is STDOUT)", false, "-", "string");
		TCLAP::ValueArg<int> argWindow("w","window","Window size for pileup (default 1024)", false, 1024, "integer");
		TCLAP::SwitchArg argAddDelAsBase("d", "adddelasbase", "Adds deletions as base", cmd, false);

		cmd.add(argInputBAMFileName);
		//cmd.add(argRefSeqFileName);
		cmd.add(argInputVCFFileName);
		cmd.add(argOutputVCFFileName);
		cmd.add(argWindow);
		cmd.parse(argc, argv);

		std::cout << "Running gpileup version " << version << std::endl; 
		std::string inputBAMFileName = argInputBAMFileName.getValue();
		std::cout << "bam file                : " << inputBAMFileName << std::endl; 
		//std::string refSeqFileName = argRefSeqFileName.getValue();	
		//std::cout << "reference sequence file : " << argRefSeqFileName.getValue() << std::endl; 
		std::string inputVCFFileName = argInputVCFFileName.getValue();
		//if input VCF is detected, look for BAM index file
		std::string inputBAMIndexFileName = "";
		if (inputVCFFileName != "")
		{
			std::cout << "input VCF file          : " << inputVCFFileName << std::endl; 
			if (inputBAMFileName.length()>4 && (inputBAMFileName.substr(inputBAMFileName.length()-4, 4) == ".bam"))
			{
				inputBAMIndexFileName.append(inputBAMFileName.c_str());
		    	inputBAMIndexFileName.append(".bai");
			}	
			std::cout << "bam index file          : " << inputBAMIndexFileName << std::endl; 
		}
		std::string outputVCFFileName = argOutputVCFFileName.getValue();

		bool inputVCFFileIsGZipped = false;
		if (outputVCFFileName.length()>3 && (outputVCFFileName.substr(outputVCFFileName.length()-3, 3) == ".gz"))
		{
			inputVCFFileIsGZipped = true;
		}
		else
		{
			inputVCFFileIsGZipped = false;
		}
	
		bool outputVCFFileIsGZipped = false;
		if (outputVCFFileName.length()>3 && (outputVCFFileName.substr(outputVCFFileName.length()-3, 3) == ".gz"))
		{
	    	std::cout << "output VCF file         : " << outputVCFFileName << " (gzip)" << std::endl; 
			outputVCFFileIsGZipped = true;
		}
		else if (outputVCFFileName=="-")
		{
			std::cout << "output VCF file         : STDOUT" << std::endl; 
			outputVCFFileIsGZipped = false;
		}
		else
		{
			std::cout << "output VCF file         : " << outputVCFFileName << std::endl; 
			outputVCFFileIsGZipped = false;
		}

		std::cout << "add deletions as bases  : " << (argAddDelAsBase.getValue()? "yes" : "no") << std::endl; 

		PileupWithoutGenomeReference<PileupElementBaseQual> pileup(argWindow.getValue(), argAddDelAsBase.getValue(), inputVCFFileIsGZipped, outputVCFFileIsGZipped);   	
		//PileupWithoutGenomeReference<PileupElementBaseQual> pileup(1000000, argAddDelAsBase.getValue(), inputVCFFileIsGZipped, outputVCFFileIsGZipped);   	
		//process file with index    	
		if (inputVCFFileName != "")
		{
		  //fprintf(stderr,"foo\n");
		  pileup.processFile(inputBAMFileName, inputBAMIndexFileName, inputVCFFileName, outputVCFFileName);
		}
		else
		{
		  pileup.processFile(inputBAMFileName, outputVCFFileName);
		}
	}
	catch (TCLAP::ArgException &e) 
	{
		std::cerr << "error: " << e.error() << " for arg " << e.argId() << std::endl;
		abort();
	}

    return(0);
}