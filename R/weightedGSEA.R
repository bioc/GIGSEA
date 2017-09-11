#' weightedGSEA
#'
#' weightedGSEA performs both SGSEA and MGSEA for a given list of gene sets, and write out the results.
#'
#' @param data a data frame comprising comlumns: gene names (characer), differential gene expression (numeric) and sample weights (numeric and optional)
#' @param geneCol an integer or a character indicating the column of gene name
#' @param fcCol an integer or a character indicating the column of differential gene expression
#' @param weightCol an integer or a character indicating the column of sample weights
#' @param geneSet a vector of characters indicating the gene sets of interest. It takes values from "MSigDB.KEGG.Pathway","MSigDB.TF","MSigDB.miRNA","Fantom5.TF","TargetScan.miRNA","GO" and "LINCS.CMap.drug"
#' @param permutationNum an integer indicating the number of permutation
#' @param outputDir a character value indicating the directory for saving the results
#' @param MGSEAthres an integer value indicating the thresfold for performing MGSEA. When the number of gene sets is smaller than MGSEAthres, we perform MGSEA.
#'
#' @return NULL
#' @export
#'
#' @examples
#'
#' library(GIGSEA)
#' library(Matrix)
#' data(heart.metaXcan)
#' gene = heart.metaXcan$gene_name
#' fc <- heart.metaXcan$zscore
#' usedFrac <- heart.metaXcan$n_snps_used / heart.metaXcan$n_snps_in_cov
#' r2 <- heart.metaXcan$pred_perf_r2
#' weights <- usedFrac*r2
#' data <- data.frame(gene,fc,weights)
#' # run one-step GIGSEA 
#' weightedGSEA(data, geneCol='gene', fcCol='fc', weightCol= 'weights', geneSet=c("MSigDB.KEGG.Pathway","Fantom5.TF","TargetScan.miRNA","GO","LINCS.CMap.drug"), permutationNum=10000, outputDir="./GIGSEA" )
#' dir("./GIGSEA")
#' 
weightedGSEA <- function( data , geneCol , fcCol , weightCol=NULL ,
                        geneSet=c("MSigDB.KEGG.Pathway","MSigDB.TF","MSigDB.miRNA","Fantom5.TF","TargetScan.miRNA","GO","LINCS.CMap.drug") ,
                        permutationNum=100 , outputDir=getwd() , MGSEAthres = NULL )
{
  
  if( !file.exists(outputDir) )
  { 
    cat('creating ' , outputDir, '\n' )
    dir.create( outputDir , showWarnings = TRUE, recursive = TRUE) 
  }
  
  allGeneSet = c("MSigDB.KEGG.Pathway","MSigDB.TF","MSigDB.miRNA","Fantom5.TF","TargetScan.miRNA","GO","LINCS.CMap.drug")
  noGeneSet = setdiff( geneSet , allGeneSet )
  if(length(noGeneSet)) cat( "Gene sets are not defined: " , noGeneSet , '\n'  )

  for( gs in intersect(geneSet,allGeneSet) )
  {

    cat('\nChecking',gs,'...\n')
    data(list=gs)
    net = get(gs)$net
    net <- net[ rownames(net) %in% as.character(data[,geneCol]) , ]
    imputeFC <- data[ match( rownames(net), as.character(data[,geneCol]) ) , ]
    fc <- imputeFC[,fcCol]

    if( is.null(weightCol) )
    {
      weights <- rep(1, nrow(net))
    } else {
      weights <- imputeFC[,weightCol]
    }

    cat('--> performing SGSEA ...\n')
    SGSEA.res <- permutationSingleLmMatrix( fc , net , weights , permutationNum )
    if( !is.null(get(gs)$annot) )
    {
      annot = get(gs)$annot
      if( all(table(annot[,1])==1) )
      SGSEA.res = merge( annot , SGSEA.res , by.x=colnames(annot)[1] , by.y=colnames(SGSEA.res)[1] )
    }
    SGSEA.res = SGSEA.res[order(SGSEA.res$empiricalPval) , ]
    write.table( SGSEA.res , paste0(outputDir,'/',gs,'.SGSEA.txt') , sep='\t' , quote=F , row.names=F , col.names=T)

    if( !is.null(MGSEAthres) )
    {
      if( ncol(net)<MGSEAthres )
      {
        cat('--> performing MGSEA ...\n')
        MGSEA.res <- permutationMultiLm( fc , net , weights , permutationNum )
        if( !is.null(get(gs)$annot) )
        {
          annot = get(gs)$annot
          if( all(table(annot[,1])==1) )
          MGSEA.res = merge( annot , MGSEA.res , by.x=colnames(annot)[1] , by.y=colnames(MGSEA.res)[1] )
        }
        MGSEA.res = MGSEA.res[order(MGSEA.res$empiricalPval) , ]
        write.table( MGSEA.res , paste0(outputDir,'/',gs,'.MGSEA.txt') , sep='\t' , quote=F , row.names=F , col.names=T)
     }
    }

  }

}
