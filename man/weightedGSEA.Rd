% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/weightedGSEA.R
\name{weightedGSEA}
\alias{weightedGSEA}
\title{weightedGSEA}
\usage{
weightedGSEA(data, geneCol, fcCol, weightCol = NULL,
  geneSet = c("MSigDB.KEGG.Pathway", "MSigDB.TF", "MSigDB.miRNA",
  "TargetScan.miRNA"), permutationNum = 100, outputDir = getwd(),
  MGSEAthres = NULL, verbose = TRUE)
}
\arguments{
\item{data}{a data frame comprising comlumns: gene names (characer), 
differential gene expression (numeric) and permuated gene weights (numeric 
and optional)}

\item{geneCol}{an integer or a character value indicating the column of gene 
name}

\item{fcCol}{an integer or a character value indicating the column of 
differential gene expression}

\item{weightCol}{an integer or a character value indicating the column of 
gene weights}

\item{geneSet}{a vector of character values indicating the gene sets of 
interest.}

\item{permutationNum}{an integer value indicating the number of permutation}

\item{outputDir}{a character value indicating the directory for saving the 
results}

\item{MGSEAthres}{an integer value indicating the thresfold for MGSEA. MGSEA 
is performed with no more than "MGSEAthres" gene sets}

\item{verbose}{an boolean value indicating whether or not to print output to 
the screen}
}
\value{
TRUE
}
\description{
weightedGSEA performs both SGSEA and MGSEA for a given list of gene sets, 
and writes out the results.
}
\examples{

data(heart.metaXcan)
gene <- heart.metaXcan$gene_name
fc <- heart.metaXcan$zscore
usedFrac <- heart.metaXcan$n_snps_used / heart.metaXcan$n_snps_in_cov
r2 <- heart.metaXcan$pred_perf_r2
weights <- usedFrac*r2
data <- data.frame(gene,fc,weights)
# run one-step GIGSEA 
# weightedGSEA(data, geneCol='gene', fcCol='fc', weightCol= 'weights', 
#    geneSet=c("MSigDB.KEGG.Pathway","MSigDB.TF","MSigDB.miRNA",
# "TargetScan.miRNA"), permutationNum=10000, outputDir="./GIGSEA" )
# dir("./GIGSEA")

}
