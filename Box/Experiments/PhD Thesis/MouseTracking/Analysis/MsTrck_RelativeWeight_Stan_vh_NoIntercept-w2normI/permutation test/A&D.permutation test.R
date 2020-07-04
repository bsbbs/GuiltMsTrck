plotdir <- 'E:/ShenBo/MouseTracking/Analysis/MsTrck_RelativeWeight_Stan_vh_NoIntercept-w2normI/permutation test'

for (context in c('swpc','swpw','scpw'))
{
  load(file.path(plotdir,sprintf('TimeAxisfit_Indvcoef_comp_%s.RData',context)))
  write.table(indvcoef.comp,file = file.path(plotdir,sprintf('TimeAxisfit_Indvcoef_comp_%s.txt',context)),row.names=F,append = FALSE, quote = F, sep = "\t", eol = "\n")
  load(file.path(plotdir,sprintf('TimeAxisfit_Indvcoef_trnsp_%s.RData',context)))
  write.table(indvcoef.trnsp,file = file.path(plotdir,sprintf('TimeAxisfit_Indvcoef_trnsp_%s.txt',context)),row.names=F,append = FALSE, quote = F, sep = "\t", eol = "\n")
}


# result fro matlab code:
# '/Users/boshen/Box/Experiments/PhD Thesis/MouseTracking/Analysis/permutation test/simulate_new.m'
point <- c(1, 2, 3, 4, 5, 6)
num <- c(70944, 11207, 585, 28, 1, 0)/100000
pval <- c(0.71, 0.11, 0.0059, 2.8e-04, 1.0e-05, 0)
cairo_pdf(file = file.path(plotdir,sprintf('Clust_permutation.pdf')),width=5,height=4, family = 'Microsoft YaHei', bg = 'transparent')
barx <- barplot(num, names = point, ylim = c(0,max(num)+0.2), main = 'permutation test', ylab = sprintf('frequency'), xlab = 'number of consecutive time bins')
text(barx,num+0.1,pval, cex = .9)
dev.off()


# [failed] individual level find start point
k_thresh = 3
indvclust <- c()
for (context in c('swpc')) # ,'swpw','scpw'
{
  load(file.path(plotdir,sprintf('TimeAxisfit_Indvcoef_comp_%s.RData',context)))
  #write.table(indvcoef.comp,file = file.path(plotdir,sprintf('TimeAxisfit_Indvcoef_comp_%s.txt',context)),row.names=F,append = FALSE, quote = F, sep = "\t", eol = "\n")
  for (subj in unique(indvcoef.comp$subid))
  {
    tmp <- indvcoef.comp[indvcoef.comp$subid == subj,]
    sigpoint <- tmp$X2.5.ile * tmp$X97.5.ile >= 0
    t <- 1
    while (t < length(sigpoint))
    {
      i <- 0
      while (sigpoint[t+i] == TRUE & (t+i <= length(sigpoint)))
      {i <- i + 1}
      if (i >= k_thresh)
      {indvclust <- rbind(indvclust,data.frame(context = context, var = 'comp', subid = subj, start = t, k = i))
      t <- t + i}
      if (i < k_thresh) {t = t + 1}
    }
  }
  
  load(file.path(plotdir,sprintf('TimeAxisfit_Indvcoef_trnsp_%s.RData',context)))
  #write.table(indvcoef.trnsp,file = file.path(plotdir,sprintf('TimeAxisfit_Indvcoef_trnsp_%s.txt',context)),row.names=F,append = FALSE, quote = F, sep = "\t", eol = "\n")
  for (subj in unique(indvcoef.trnsp$subid))
  {
    tmp <- indvcoef.trnsp[indvcoef.trnsp$subid == subj,]
    sigpoint <- tmp$X2.5.ile * tmp$X97.5.ile >= 0
    t <- 1
    while (t < length(sigpoint))
    {
      i <- 0
      while (sigpoint[t+i] == TRUE & (t+i <= length(sigpoint)))
      {i <- i + 1}
      if (i >= k_thresh)
      {indvclust <- rbind(indvclust,data.frame(context = context, var = 'trnsp', subid = subj, start = t, k = i))
      t <- t + i}
      if (i < k_thresh) {t = t + 1}
    }
  }
  
}
