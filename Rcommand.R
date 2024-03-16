install.packages("package_name")    #安装包
installed.packages()                #列出所有已安装的包
installed.packages("package_name")  #列出指定包的信息
library(package_name)               #加载包
(.packages())                       #列出当前已加载的包
detach("package:package_name")      #卸载包

#读取Excel的.xlsx文件
library(openxlsx)
mydata = read.xlsx("/path/mydata.xlsx", sheet = 1)    #读取指定路径下的excel文件

#绘制基因图谱,如Rplot1.png所示
library(ggplot2)
library(gggens)
library(openxlsx)
mydate = read.xlsx("/path/mydata.xlsx", sheet = 1)    #读取指定路径下的excel文件,mydata如下
    Genome	    Gene	        start	end
    JLDX0004	sorbose_EIIC_1	100     903
    JLDX0004	sorbose_EIIC_2	1003	1839
    JLDX0004	sorbose_EIIC_3	1939	2742
    JLDX0007	sorbose_EIIC_1	100	    903
    JLDX0007	sorbose_EIIC_2	1003	1839
    JLDX0007	sorbose_EIIC_3	1939	2742
    JLDX0002	sorbose_EIIC_1	100	    903
    JLDX0002	sorbose_EIIC_2	1003	1839
    JLDX0002	sorbose_EIIC_3	1939	2742
    JLDX0002	sorbose_EIIC_4	2842	3693
    JLDX0002	sorbose_EIIC_5	3793	4578
    JLDX0002	galactitol_EIIC	4678	6081
    SZXJY0012	sorbose_EIIC	100	    903
    SZXJY0012	sorbose_EIIC_2	1003	1839
    SZXJY0012	sorbose_EIIC_3	1939	2742
    SZXJY0012	sorbose_EIIC_4	2842	3693
    SZXJY0012	sorbose_EIIC_6	3793	4584
    SZXJY0012	sorbose_EIIC_7	4684	5454
    SZXJY0012	galactitol_EIIC	5554	6957
mydata$Gene<-factor(mydata3$Gene,levels = c("sorbose_EIIC_1","sorbose_EIIC_2","sorbose_EIIC_3","sorbose_EIIC_4","sorbose_EIIC_5","sorbose_EIIC_6","sorbose_EIIC_7","sorbose_EIIC","galactitol_EIIC"))
ggplot(mydata, aes(xmin = start, xmax = end, y = Genome, fill = Gene)) +  geom_gene_arrow() +  scale_fill_brewer(palette = "Set3") +  theme_genes() #绘制基因图，结果如Rplot1.png所示

#绘制环形关系图
library(circlize)
from = mydata[[1]]
to = mydata[[2]]
value = mydata[[3]]
df = data.frame(from, to, value)
chordDiagram(df)