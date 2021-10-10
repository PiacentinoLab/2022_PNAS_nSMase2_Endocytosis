# DESeq2 Analysis

# Update following input parameters and variables, then subsequent code blocks are soft-coded to read from these values
countdata <- read.table("../Inputs/featureCounts_8ss_vs_5ss.txt", header=TRUE, row.names=1)
analysis_name <- 'Chick_8ssvs5ss'
pop1_name <- '8ss_NC'
pop1_reps <- 4
pop2_name <- '5ss_NC'
pop2_reps <- 4

# Convert to matrix
countdata <- as.matrix(countdata)
head(countdata)

# Assign condition (first 2 are positive--second 2 are negative)
(condition <- factor(c(rep(pop1_name, pop1_reps), rep(pop2_name, pop2_reps))))

# Start DESeq2
library(DESeq2)

# Create DESeq2 Dataset
(coldata <- data.frame(row.names=colnames(countdata), condition))
dds <- DESeqDataSetFromMatrix(countData=countdata, colData=coldata, design=~condition)
dds

# Run the DESeq pipeline
dds <- DESeq(dds)

# Plot dispersions
png(paste(analysis_name, 'qc_dispersion.png', sep = "_", collapse = NULL), 1000, 1000, pointsize=20)
plotDispEsts(dds, main=paste(analysis_name, 'Dispersion Plot.png', sep = " ", collapse = NULL))
dev.off()

# Regularized log transformation for clustering/heatmaps, etc
rld <- rlogTransformation(dds)
head(assay(rld))
hist(assay(rld))

# Colors for plots below
## Ugly:
## (mycols <- 1:length(unique(condition)))
## Use RColorBrewer, better
library(RColorBrewer)
(mycols <- brewer.pal(3, "Purples")[1:length(unique(condition))])

# Sample distance heatmap
sampleDists <- as.matrix(dist(t(assay(rld))))

library(gplots)

png(paste(analysis_name, 'qc_heatmap_samples.png', sep = "_", collapse = NULL), 1000, 1000, pointsize=20)
heatmap.2(as.matrix(sampleDists), key=F, trace="none",
          col=colorpanel(100, "black", "white"),
          ColSideColors=mycols[condition], RowSideColors=mycols[condition],
          margin=c(10, 10), main="Sample Distance Matrix")
dev.off()

# Principal components analysis
## Could do with built-in DESeq2 function:
## DESeq2::plotPCA(rld, intgroup="condition")
## I like mine better: (From Megan Martik)
rld_pca <- function (rld, intgroup = "condition", ntop = 500, colors=NULL, legendpos="bottomleft", main="PCA Biplot", textcx=1, ...) {
  require(genefilter)
  require(calibrate)
  require(RColorBrewer)
  rv = rowVars(assay(rld))
  select = order(rv, decreasing = TRUE)[seq_len(min(ntop, length(rv)))]
  pca = prcomp(t(assay(rld)[select, ]))
  fac = factor(apply(as.data.frame(colData(rld)[, intgroup, drop = FALSE]), 1, paste, collapse = " : "))
  if (is.null(colors)) {
    if (nlevels(fac) >= 3) {
      colors = brewer.pal(nlevels(fac), "Paired")
    }   else {
      colors = c("black", "red")
    }
  }
  pc1var <- round(summary(pca)$importance[2,1]*100, digits=1)
  pc2var <- round(summary(pca)$importance[2,2]*100, digits=1)
  pc1lab <- paste0("PC1 (",as.character(pc1var),"%)")
  pc2lab <- paste0("PC1 (",as.character(pc2var),"%)")
  plot(PC2~PC1, data=as.data.frame(pca$x), bg=colors[fac], pch=21, xlab=pc1lab, ylab=pc2lab, main=main, ...)
  with(as.data.frame(pca$x), textxy(PC1, PC2, labs=rownames(as.data.frame(pca$x)), cex=textcx))
  legend(legendpos, legend=levels(fac), col=colors, pch=20)
  #     rldyplot(PC2 ~ PC1, groups = fac, data = as.data.frame(pca$rld),
  #            pch = 16, cerld = 2, aspect = "iso", col = colours, main = draw.key(key = list(rect = list(col = colours),
  #                                                                                         terldt = list(levels(fac)), rep = FALSE)))
}
png(paste(analysis_name, 'pca.png', sep = "_", collapse = NULL), 1000, 1000, pointsize=20)
rld_pca(rld, colors=mycols, intgroup="condition", xlim=c(-200, 200), ylim=c(-200, 200))
dev.off()


# Get differential expression results
res <- results(dds)
table(res$padj<0.05)

## Order by adjusted p-value
res <- res[order(res$padj), ]

## Merge with normalized count data
resdata <- merge(as.data.frame(res), as.data.frame(counts(dds, normalized=TRUE)), by="row.names", sort=FALSE)

# Change first column name to Gene id
names(resdata)[1] <- "Gene id"
head(resdata)

## Write results
write.csv(resdata, file=paste(analysis_name, 'DESeq2_results.csv', sep = "_", collapse = NULL))

