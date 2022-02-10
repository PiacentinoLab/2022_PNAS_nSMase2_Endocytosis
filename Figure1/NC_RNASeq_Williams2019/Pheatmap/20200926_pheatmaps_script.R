# Script adapted from Ivan Candido-Ferriera

library(RColorBrewer)
library(scales)
library(pheatmap)
library(viridis)
library(seriation)
library(ggplot2)

raw_data <- as.data.frame(read.csv('../20220210 GO term name lipid sigDEGS featureCounts.csv'))
outputname <- '20220210 GO term name lipid sigDEGS heatmap reflected.png'

counts <- raw_data
rownames(counts) <- NULL
dim(counts)

dat <- counts[,5:15]  # numerical columns
dat<- as.matrix(dat)
counts <- as.data.frame(counts)
rownames(dat) <- counts$GeneName
dat[is.na(dat)] <- 0

callback = function(hc, dat){
  sv = rev(svd(t(dat))$v[,9])
  dend = reorder(as.dendrogram(hc), wts = sv)
  as.hclust(dend)
}

heatmap <- pheatmap(mat = dat, filename = outputname,
         
         #Provide clustering parameters
         scale = "row", clustering_method = "complete",
         cluster_rows = TRUE, clustering_distance_rows = "euclidean", 
         cluster_cols = TRUE, clustering_distance_cols = "euclidean", 
         clustering_callback = callback,
         #kmeans_k = 5,
        
         # Define color scheme
         border="gray40", 
         #color = colorRampPalette(rev(brewer.pal(n = 10, name ="RdYlBu")))(100),
         #color = colorRampPalette(c("blue","white", "red"))(50),
         color = viridis(100, direction = 1, option = 'viridis'),

         # Other customizations
         main = "Relative expression of lipid effector genes",
         cutree_rows = 3, cutree_cols=3,
         show_rownames = TRUE, show_colnames = TRUE,
         )

ggsave(outputname, heatmap, bg = "transparent")

