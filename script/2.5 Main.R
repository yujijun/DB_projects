# --------------
# Date:  2019-12-23 12:07:18 
# Modification date:  2019-01-02 17:54:18
# Author:JijunYu
# Email: jijunyu140@gmail.com
# --------------
# About project:
#This is main function for all RNAseq analysis
#I can package all function I need into /R folder, but must make all computational process clearly 
#under main function. split the code according to the function of the module.
library(readxl)
library(DESeq2)
library(data.table)
library(tidyverse)
library(ggplot2)
library(pheatmap)
library(ggpubr)
library(methods)
library(edgeR)
library(limma)
library(gplots)
library(org.Hs.eg.db)
library(RColorBrewer)
library(statmod)
require(clusterProfiler)
library("BiocParallel")
register(MulticoreParam(4))
options(stringsAsFactors = F)

#parameter:
contrast <- c("group","BD","HC")
output <- "/Users/yujijun/Documents/01-Work/06-BD_project/BD_projects/output_BDV6"
annocol <- c(rep("HC",10),rep("BD",8))
annocol <- as.data.frame(annocol)
rownames(annocol) <- colnames(expr.count)
genelist <- c("C1QA","C1QB","C1QC","FCER1A","HLA-DPA1","HLA-DPB1","HLA-DQA1","HLA-DRB1")
topnum <- 20
bottomnum <- 20 
genenum <- 20 
prefix.main  <- "BDvsHC"
height <- 20
width <- 20
clustercol  <- F
clusterrow <- F
intgroup <- c("group")
#1. DEgene module####
DEgene <- function(dds_tmp,contrast,output){
  #dds_tmp is the dds file after DESeq() generated from 1.Generate_DESeqDataSet.R 
  #contrast: a vector, for example: contrast = c("patient","BDV","HC")
  #output: the a foldr for all DEgene related result
  res_dds <- results(dds_tmp, contrast=contrast)
  res_dds_df <- as.data.frame(res_dds)
  res_dds_df <- res_dds_df[order(res_dds_df$padj),]
  outpath.DEgene <- paste(output,"/DEgene",sep = "")
  ifelse(!dir.exists(outpath.DEgene),dir.create(outpath.DEgene),FALSE)
  output.name <- paste(contrast[2],"_vs_",contrast[3],".txt",sep = "")
  write.table(res_dds_df,file =paste(outpath.DEgene,output.name,sep = "/"),col.names = T, row.names = T,sep = "\t")
  output.plotMAmainname <- paste(contrast[2],"_vs_",contrast[3],sep = "")
  output.plotMAfigurename <- paste(output.plotMAmainname,".png",sep = "")
  png(paste(outpath.DEgene,output.plotMAfigurename,sep = "/"),height = 10,width = 10,units ="cm",res=150)
  plotMA(res_dds,main=output.plotMAmainname)
  dev.off()
  return(res_dds_df)
}

#output up and down regulator gene matrix in speific LFC and matrix.
contrast <- c("group","BD","HC")
DEmatrix <- DEgene(dds_tmp,contrast,output)
DEmatrix.sign <- DEmatrix[DEmatrix$log2FoldChange >1 & DEmatrix$padj < 0.05,]
DEmatrix.sign <- DEmatrix.sign[order(DEmatrix.sign$log2FoldChange,decreasing = T),]
DEmatrix.sign <- DEmatrix.sign[complete.cases(DEmatrix.sign),]
write.table(DEmatrix.sign,file = "./data-raw/DEmatrix.sign.txt",sep = "\t",row.names = T,col.names = T)
#down-regulator gene set:
DEmatrix.downsign <- DEmatrix[DEmatrix$log2FoldChange < -1 & DEmatrix$padj <0.05,]
DEmatrix.downsign <- DEmatrix.downsign[complete.cases(DEmatrix.downsign),]
DEmatrix.downsign <- DEmatrix.downsign[order(DEmatrix.downsign$log2FoldChange),]
write.table(DEmatrix.downsign,file = "./data-raw/DEmatrix.downsign.txt",sep = "\t",row.names = T,col.names = T)


##2. Visulation for DEgene####
#2.1 heatmap#
DEgene_heatmap <- function(dds_tmp,DEmatrix, topnum, bottomnum,annocol,clustercol=F,clusterrow=F,output,prefix.main,height,width){
  #dds_tmp is the dds file after DESeq() generated from 1.Generate_DESeqDataSet.R 
  #DEmatrix is a dataframe generated by last function DEgene.
  #topnum: how much upregulater genes do you want to show.
  #bottomnum: how much downregulater genes do you want to show.
  #annocol: A dataframe: rownames are sample names;
  #output: the a foldr for all DEgene related result;
  #prefix.main: a character, which is a marker for specific analysis;
  #height: height of heatmap figure;
  #width:width of heatmap figure;
  require(pheatmap)
  main = paste0(prefix.main,"_degene_heatmap",sep = "")
  DEmatrix <- DEmatrix[order(DEmatrix$padj,decreasing = T),]
  DEmatrix <- DEmatrix[order(DEmatrix$log2FoldChange,decreasing = T),]
  topgene <- rownames(DEmatrix[1:topnum,])
  DEmatrix <- DEmatrix[order(DEmatrix$padj),]
  DEmatrix <- DEmatrix[order(DEmatrix$log2FoldChange),]
  downgene <- rownames(DEmatrix[1:bottomnum,])
  rld_BDUV <- rlog(dds_tmp, blind = FALSE) #this transform is useful when checking for outliers 
  #or as input for machine learning techniques such as clustering or linear discriminant analysis.
  mat  <- assay(rld_BDUV)[c(topgene,downgene), ]
  mat  <- mat - rowMeans(mat)
  upordown = c(rep("up",topnum),rep("down",bottomnum))
  annorow <- as.data.frame(upordown) # a dataframe: rownames are gene vector.
  rownames(annorow) <- c(topgene,downgene)
  p <- pheatmap(mat,annotation_col = annocol,annotation_row=annorow,cluster_cols = clustercol,cluster_rows = clusterrow,main = main)
  figure.name <- paste(main,".png",sep = "")
  outpath.DEgene <- paste(output,"DEgene",sep = "/")
  ifelse(!dir.exists(outpath.DEgene),dir.create(outpath.DEgene),FALSE)
  png(paste(outpath.DEgene,figure.name,sep = "/"),height = height,width=width,units="cm",res = 150)
  print(p)
  dev.off()
}
#test heatmap function
annocol <- c(rep("HC",10),rep("BD",8))
annocol <- as.data.frame(annocol)
rownames(annocol) <- colnames(expr.count)
DEgene_heatmap(dds_tmp,DEmatrix,topnum = 50,bottomnum = 50,annocol = annocol,clustercol=F,clusterrow=T,output,prefix.main = "BDvsHC",height = 40,width = 20)

#Heatmap specific
Heatmap_specific <- function(dds_tmp,genelist,prefix.main,output,height,width){
  require(pheatmap)
  main=paste0(prefix.main,"_heatmap_specific",sep = "")
  rld <- rlog(dds_tmp, blind = FALSE)
  mat  <- assay(rld)[genelist, ]
  mat  <- mat - rowMeans(mat)
  p <- pheatmap(mat,cluster_cols = F,main = main,show_rownames = T)
  figure.name <- paste(main,".png",sep = "")
  outpath.DEgene <- paste(output,"DEgene",sep = "/")
  ifelse(!dir.exists(outpath.DEgene),dir.create(outpath.DEgene),FALSE)
  png(paste(outpath.DEgene,figure.name,sep = "/"), height = height, width=width, units="cm",res = 150)
  print(p)
  dev.off()
}
Heatmap_specific_median <- function(dds_tmp,genelist,prefix.main,output,height,width){
  require(pheatmap)
  main=paste0(prefix.main,"_heatmap_specific",sep = "")
  rld <- rlog(dds_tmp, blind = FALSE)
  mat  <- assay(rld)[genelist, ]
  mat  <- mat - apply(mat, 1, median)
  p <- pheatmap(mat,cluster_cols = F,main = main)
  figure.name <- paste(main,".png",sep = "")
  outpath.DEgene <- paste(output,"DEgene",sep = "/")
  ifelse(!dir.exists(outpath.DEgene),dir.create(outpath.DEgene),FALSE)
  png(paste(outpath.DEgene,figure.name,sep = "/"), height = height, width=width, units="cm",res = 150)
  print(p)
  dev.off()
}
Heatmap_specific_scale <- function(dds_tmp,genelist,prefix.main,output,height,width){
  require(pheatmap)
  main=paste0(prefix.main,"_heatmap_specific",sep = "")
  rld <- rlog(dds_tmp, blind = FALSE)
  mat  <- assay(rld)[genelist, ]
  mat <- t(scale(t(mat)))
  #mat  <- mat - apply(mat, 1, median)
  p <- pheatmap(mat,cluster_cols = F,main = main)
  figure.name <- paste(main,".png",sep = "")
  outpath.DEgene <- paste(output,"DEgene",sep = "/")
  ifelse(!dir.exists(outpath.DEgene),dir.create(outpath.DEgene),FALSE)
  png(paste(outpath.DEgene,figure.name,sep = "/"), height = height, width=width, units="cm",res = 150)
  print(p)
  dev.off()
}

upgene <- DEmatrix[DEmatrix$log2FoldChange>0.7 & DEmatrix$padj <0.05,]
upgene <- upgene[complete.cases(upgene),]
upgene <- rownames(upgene)
rld <- rlog(dds_tmp, blind = FALSE)
mat  <- assay(rld)[upgene, ]
mat <- t(scale(t(mat)))
#mat  <- mat - apply(mat, 1, median)
p <- pheatmap(mat,cluster_cols = F,main = main)
eg = bitr(upgene, fromType="SYMBOL", toType="ENTREZID", OrgDb="org.Hs.eg.db")
mkk <- enrichKEGG(gene = eg$ENTREZID,organism = 'hsa')
figure.name <- 'KEGG pathway in BDvsHC'
p1 <- dotplot(mkk,title = figure.name)
p1 + theme(plot.title = element_text(face = "bold",hjust = 0.5,size = 15)) 
#
i =5
print(mkk$Description[i])
UpgeneID <- str_split(mkk$geneID[i],"/")[[1]]
complement <- bitr(UpgeneID, fromType="ENTREZID", toType="SYMBOL", OrgDb="org.Hs.eg.db")
complement.gene <- as.character(complement$SYMBOL)
write(complement.gene,"~/Desktop/complementary.txt",sep = "\t")
rld <- rlog(dds_tmp, blind = FALSE)
mat  <- assay(rld)[complement.gene, ]
mat <- t(scale(t(mat)))
#mat  <- mat - apply(mat, 1, median)
annocol <- c(rep("HC",10),rep("BD",8))
annocol <- as.data.frame(annocol)
rownames(annocol) <- colnames(expr.count)
p <- pheatmap(mat,cluster_cols = F,main = main,annotation_col = annocol)
write(complement.gene,file="~/Desktop/complement.txt",sep = "\t")


p <- pheatmap(mat,cluster_cols = F,main = main)
#draw all up regulator gene list
gene <- c(rownames(DEmatrix.sign))
Heatmap_specific(dds_tmp = dds_tmp, genelist = gene,prefix.main = "BDvsHC",output = output,height = 300,width = 10)

#draw the specific gene set in cluster.
rld <- rlog(dds_tmp, blind = FALSE)
mat  <- assay(rld)[genelist, ]
mat  <- mat - rowMeans(mat)
mat <- mat[geneset1,]
mat <- t(scale(t(mat)))
p <- pheatmap(mat,cluster_cols = F,,main = main,show_rownames = T)
geneset1 <- p$tree_row$labels[p$tree_row$order][1:19]
Heatmap_specific(dds_tmp = dds_tmp, genelist = geneset1,prefix.main = "BDvsHC_geneset1",output = output,height = 10,width = 10)
geneset2 <- p$tree_row$labels[p$tree_row$order][1256:length(p$tree_row$labels)]
Heatmap_specific(dds_tmp = dds_tmp, genelist = geneset2,prefix.main = "BDvsHC_geneset2",output = output,height = 30,width = 10)

#draw all down regulator gene list
gene_down <- c(rownames(DEmatrix.downsign))
Heatmap_specific(dds_tmp = dds_tmp, genelist = gene_down,prefix.main = "BDvsHC_down",output = output,height = 300,width = 10)
#draw the specific gene set with cluster order:
rld <- rlog(dds_tmp, blind = FALSE)
mat  <- assay(rld)[gene_down, ]
mat  <- mat - rowMeans(mat)
p <- pheatmap(mat,cluster_cols = F,main = main,show_rownames = F)
print(which(p$tree_row$labels[p$tree_row$order] == "SGCD"))
geneset4<- p$tree_row$labels[p$tree_row$order][34:111]
Heatmap_specific(dds_tmp = dds_tmp, genelist = geneset1,prefix.main = "BDvsHC_downgeneset3",output = output,height = 40,width = 10)


##Prepare tpm expression
main=paste0(prefix.main,"_heatmap_specific",sep = "")
expr.tpm <- read.table("./data-raw/expr.tpm.company.expression.genename",header = T,sep = "\t")
rownames(expr.tpm) <- expr.tpm[,1]
expr.tpm <- expr.tpm[,-1]
expr.tpm <- expr.tpm[rowSums(expr.tpm) >= 10,]
expr.tpm <- expr.tpm[,-19]
expr.tpm <- log2(expr.tpm+1)
expr.tpm.tmp <- expr.tpm[gene,]
expr.tpm.tmp <- expr.tpm.tmp - rowMeans(expr.tpm.tmp)
#expr.tpm.tmp <- expr.tpm.tmp - apply(expr.tpm.tmp, 1, median)
pheatmap(expr.tpm.tmp,cluster_cols = F,main = main)
#if we need to display heatmap by log2(TPM+1) and

#2.2 volcano plot
volcanodisplaymultigene <- function(DEmatrix,genenum,prefix.main,output,height,width){
  main=paste(prefix.main,"_volcano_plot",sep = "")
  source('./R/Volcano.R')
  BDUup.gene = DEmatrix %>% 
    rownames_to_column(var = 'gene') %>%
    filter(log2FoldChange>1, padj<0.01)
  BDUup.gene <- BDUup.gene[order(BDUup.gene$log2FoldChange,decreasing = T),]
  Top20up <- BDUup.gene[1:genenum,] %>%  pull(gene)
  BDUdown.gene = DEmatrix %>% 
    rownames_to_column(var = 'gene') %>%
    filter(log2FoldChange<(-1), padj<0.01)
  BDUdown.gene <- BDUdown.gene[order(BDUdown.gene$log2FoldChange),]
  Top20down <- BDUdown.gene[1:genenum,] %>%  pull(gene)
  
  dd.rra = DEmatrix
  dd.rra$Official = toupper(rownames(DEmatrix))
  if(sum(Top20up %in% dd.rra$Official) > 0){
    dd.rra$color <- "background"
    dd.rra$log_10 <- -log10(dd.rra$padj)
    dd.rra$color[dd.rra$Official %in% Top20up] <- "Topup"
    dd.rra$color[dd.rra$Official %in% Top20down] <- "Topdown"
    figure_title = main
    subset = dd.rra[dd.rra$Official %in% c(Top20up,Top20down),]
    #draw the plot
    p<-Volcano(data=dd.rra, x="log2FoldChange",y="log_10",
               label_data = subset,fill="color",
               color="color",label = "Official",color_palette = c("#CFCFCF","#228B22","#FF0000"),title=main)  #+ geom_text_repel(data = subset,aes(x = LFC, y = FDR),label = Official)
    #save the plot
    figure_output = paste(main,".png",sep = "")
    outpath.DEgene <- paste(output,"DEgene",sep = "/")
    ifelse(!dir.exists(outpath.DEgene),dir.create(outpath.DEgene),FALSE)
    png(paste(outpath.DEgene,figure_output,sep = "/"),height = height,width = width,units ="cm",res=150)
    print(p)
    dev.off()
  }else{
    print(paste("There isn't gene in ",figure_name))
  }
}
###3. Enrichment####
Upenrichment_plot <- function(DEmatrix, LFC=1, Padj=0.05,prefix.main,height,width,output){
  main = paste(prefix.main,"_upgene_enrichment",sep = "")
  require(clusterProfiler)
  up.gene = DEmatrix %>% 
    rownames_to_column(var = 'gene') %>%
    filter(log2FoldChange>LFC, padj<Padj) %>% 
    pull(gene)
  print(paste("The number of Upgene is:",length(up.gene),sep = " "))
  eg = bitr(up.gene, fromType="SYMBOL", toType="ENTREZID", OrgDb="org.Hs.eg.db")
  mkk <- enrichKEGG(gene = eg$ENTREZID,organism = 'hsa')
  
  #output all pathway gene list
  outpath.Enrichment <- paste(output,"Enrichment",sep = "/")
  ifelse(!dir.exists(outpath.Enrichment),dir.create(outpath.Enrichment),FALSE)
  for(i in seq(1,length(mkk$Description))){
    pathwayfilename_tmp <- paste0("Upenrichment_",mkk$Description[i],sep = "")
    sink(paste(outpath.Enrichment,pathwayfilename_tmp,sep = "/"))
    print(mkk$Description[i])
    UpgeneID <- str_split(mkk$geneID[i],"/")[[1]]
    print(bitr(UpgeneID, fromType="ENTREZID", toType="SYMBOL", OrgDb="org.Hs.eg.db"))
    sink()
  }
  #print all pathway info
  sink(paste(outpath.Enrichment,"All_upenrichemnt_pathway.txt",sep = "/"))
  print(mkk$Description)
  sink()
  
  #print enrichment figure
  figure.name <- 'KEGG pathway in BDvsHC'
  p1 <- dotplot(mkk,title = figure.name)
  p1 + theme(plot.title = element_text(face = "bold",hjust = 0.5,size = 15)) 
    #labs(subtitle=paste("The number of Upgene is:",length(up.gene),sep = " "))
  figure.output <- paste(main,".png",sep = "")
  png(paste(outpath.Enrichment,figure.output,sep = "/"),height = height,width=width,units="cm",res = 150)
  print(p1)
  dev.off()
}
Downenrichment_plot <- function(DEmatrix, LFC=0, Padj=0.05,prefix.main,height,width,output){
  main = paste(prefix.main,"_downgene_enrichment",sep = "")
  require(clusterProfiler)
  down.gene = DEmatrix %>% 
    rownames_to_column(var = 'gene') %>%
    filter(log2FoldChange<(-LFC), padj<Padj) %>% 
    pull(gene)
  print(paste("The number of Downgene is:",length(down.gene),sep = " "))
  eg.d = bitr(down.gene, fromType="SYMBOL", toType="ENTREZID", OrgDb="org.Hs.eg.db")
  mkk.d <- enrichKEGG(gene = eg.d$ENTREZID,organism = 'hsa')
  
  #output all pathway gene list
  outpath.Enrichment <- paste(output,"Enrichment",sep = "/")
  ifelse(!dir.exists(outpath.Enrichment),dir.create(outpath.Enrichment),FALSE)
  for(i in seq(1,length(mkk.d$Description))){
    pathwayfilename_tmp <- paste0("Downenrichment_",mkk.d$Description[i],sep = "")
    sink(paste(outpath.Enrichment,pathwayfilename_tmp,sep = "/"))
    print(mkk.d$Description[i])
    UpgeneID <- str_split(mkk.d$geneID[i],"/")[[1]]
    print(bitr(UpgeneID, fromType="ENTREZID", toType="SYMBOL", OrgDb="org.Hs.eg.db"))
    sink()
  }
  #print all pathway info
  sink(paste(outpath.Enrichment,"All_Downenrichemnt_pathway.txt",sep = "/"))
  print(mkk.d$Description)
  sink()
  p2 <- dotplot(mkk.d,title = paste('Downregulated KEGG pathway in',main,"patients","(",LFC,",",Padj,")",sep = " "))
  p2 + theme(plot.title = element_text(face = "bold",hjust = 0.5,size = 10)) +
    labs(subtitle=paste("The number of Downgene is:",length(down.gene),sep = " "))
  figure.name <- paste(main,".png",sep = "")
  png(paste(outpath.Enrichment,figure.name,sep = "/"),height = height,width=width,units="cm",res = 150)
  print(p2)
  dev.off()
}
#Tes
Upenrichment_plot(DEmatrix,LFC=1,Padj = 0.05,prefix.main = "BDvsHC",height = 20,width = 20,output)
# Downenrichment_plot(DEmatrix,LFC=0,Padj = 0.05,prefix.main = "BDvsHC",height = 20,width = 20,output)
#specific gene enrichment
allgene <- rownames(DEmatrix[DEmatrix$padj < 0.05 & DEmatrix$log2FoldChange>0,])
eg = bitr(geneset1, fromType="SYMBOL", toType="ENTREZID", OrgDb="org.Hs.eg.db")
mkk <- enrichKEGG(gene = eg$ENTREZID,organism = 'hsa')
figure.name <- 'KEGG pathway in BDvsHC'
p1 <- dotplot(mkk,title = figure.name)
p1 + theme(plot.title = element_text(face = "bold",hjust = 0.5,size = 15)) 

#there is a question, for all gene together, I can't find the enrichment KEGG, So if there are some 
#there are some other method I can do, The first thing I can do is that try another different 
#method to do it again. (When there are too much noisy gene, It's not very unfavorable for enrichment analysis.)

####4. distance between samples####
#4.1 Euclidean distance
Eucli.dis.plot <- function(dds_tmp,prefix.main,height,width,output){
  require("pheatmap")
  require("RColorBrewer")
  main = paste(prefix.main,"_Euclidean_distance",sep = "")
  rld <- rlog(dds_tmp, blind = FALSE)
  sampleDists <- dist(t(assay(rld)))
  sampleDistMatrix <- as.matrix(sampleDists)
  colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
  p <- pheatmap(sampleDistMatrix,
           clustering_distance_rows = sampleDists,
           clustering_distance_cols = sampleDists,
           col = colors,main = main)
  figure.name <- paste(main,".png",sep = "")
  outpath.sampledis <- paste(output,"SampleDistance",sep = "/")
  ifelse(!dir.exists(outpath.sampledis),dir.create(outpath.sampledis),FALSE)
  png(paste(outpath.sampledis,figure.name,sep = "/"),height = height,width=width,units="cm",res = 150)
  print(p)
  dev.off()
}
#4.2 poisson distance
poiss.dis.plot <- function(dds_tmp,prefix.main,height,width,output){
  require("PoiClaClu")
  require("RColorBrewer")
  main = paste(prefix.main,"_poisson_distance",sep = "")
  poisd <- PoissonDistance(t(counts(dds_tmp)))
  sampleDists <- poisd$dd
  sampleDistMatrix <- as.matrix(sampleDists)
  colnames(sampleDistMatrix) <- c(paste0("HC",seq(1,10)),paste0("BDU",seq(1,3)),paste0("BDV",seq(1,5)))
  rownames(sampleDistMatrix) <- c(paste0("HC",seq(1,10)),paste0("BDU",seq(1,3)),paste0("BDV",seq(1,5)))
  colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
  p <- pheatmap(sampleDistMatrix,
           clustering_distance_rows = ,
           clustering_distance_cols = ,
           col = colors,main = main)
  figure.name <- paste(main,".png",sep = "")
  outpath.sampledis <- paste(output,"SampleDistance",sep = "/")
  ifelse(!dir.exists(outpath.sampledis),dir.create(outpath.sampledis),FALSE)
  png(paste(outpath.sampledis,figure.name,sep = "/"),height = height,width=width,units="cm",res = 150)
  print(p)
  dev.off()
}
#4.3 pca
PCA.plot <- function(dds_tmp,intgroup,height,width,prefix.main,output){
  #intgroup:interesting groups: a character vector of names in colData(x) to use for grouping
  main = paste(prefix.main,"_PCAplot",sep = "")
  rld <- rlog(dds_tmp, blind = FALSE)
  pcaData <- plotPCA(rld, intgroup = intgroup, returnData = TRUE)
  percentVar <- round(100 * attr(pcaData, "percentVar"))
  p <- ggplot(pcaData, aes(x = PC1, y = PC2, color = pcaData[,intgroup])) +
    geom_point(size =2) +
    labs(title = main) +
    xlab(paste0("PC1: ", percentVar[1], "% variance")) +
    ylab(paste0("PC2: ", percentVar[2], "% variance")) +
    coord_fixed()+
    ggrepel::geom_label_repel(aes(label=name),data = pcaData ) + 
    theme(plot.title = element_text(hjust = 0.5,face = "bold",size = 20) ) + 
    theme(plot.margin = unit(c(1,1,1,1), "cm")) 
  figure.name <- paste(main,".png",sep = "")
  outpath.sampledis <- paste(output,"SampleDistance",sep = "/")
  ifelse(!dir.exists(outpath.sampledis),dir.create(outpath.sampledis),FALSE)
  png(paste(outpath.sampledis,figure.name,sep = "/"),height = height,width=width,units="cm",res = 150)
  print(p)
  dev.off()
}

#test
# Eucli.dis.plot(dds_tmp,prefix.main = "BDvsHC",height = 20,width = 20,output)
# poiss.dis.plot(dds_tmp,prefix.main = "BDvsHC",height = 20,width = 20,output)
# PCA.plot(dds_tmp,intgroup = "group",prefix.main = "BDvsHC",height = 20,width = 20,output)

#workflow####
# Workflow <- function(dds_tmp,contrast,topnum,bottomnum,genenum,annocol,output,specific.gene=T,genelist,prefix.main,height,width,clustercol,clusterrow,
#                      LFC=1,Padj=0.05,intgroup){
#   #DEgene
#   print("Calculating DEgene now......")
#   DEmatrix <- DEgene(dds_tmp,contrast = contrast, output)
#   print("Congratulation on you, DEgene was all done.")
#   #heatmap
#   print("Generating heatmap now......")
#   DEgene_heatmap(dds_tmp,DEmatrix,topnum,bottomnum,annocol = annocol,clustercol,clusterrow,output,prefix.main,height,width)
#   if(specific.gene == T){
#     DEgene_heatmap_specific(dds_tmp,genelist,prefix.main,output,height,width)
#   }
#   #volcanoplot
#   print("Generating volcano plot now......")
#   volcanodisplaymultigene(DEmatrix,genenum,prefix.main,output,height,width)
#   #Enrichment
#   print("Generating enrichment result now......")
#   #Upenrichment_plot(DEmatrix,LFC = 1,Padj,prefix.main,height,width,output)
#   #Downenrichment_plot(DEmatrix,LFC = 1,Padj,prefix.main,height,width,output)
#   #sample distance
#   print("Generating sample distance results now......")
#   Eucli.dis.plot(dds,prefix.main,height,width,output)
#   poiss.dis.plot(dds,prefix.main,height,width,output)
#   PCA.plot(dds,intgroup,height,width,prefix.main,output)
# }

#Running####

Workflow(dds_tmp,contrast,topnum,bottomnum,genenum,annocol,output,specific.gene=T,genelist,prefix.main,height,width,clustercol,clusterrow,
         LFC=1,Padj=0.05,intgroup)

####Parameter####
# option_list = list(
#   make_option(c("-i", "--input"), type="character", default=NULL,
#               help="input file in DESeqDataSeq format", metavar="character"),
#   make_option(c("-o", "--out"), type="character", default="./",
#               help="output folder [default= %default]", metavar="character"),
#   make_option(c("-c", "--contrast"), type="vector", default=c("patient","BD","HC"),
#               help="this argument specifies what comparison to 
#               extract from the object to build a results table", metavar="character")
# );
# #check input parameters
# opt_parser <- OptionParser(option_list=option_list);
# opt <- parse_args(opt_parser);
# if (is.null(opt$file)){
#   print_help(opt_parser)
#   stop("At least one argument must be supplied (input file).\n", call.=FALSE)
# }
# dds <- opt$input
# output <- opt$out
# contrast <- opt$contrast
