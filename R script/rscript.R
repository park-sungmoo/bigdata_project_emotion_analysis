setwd("C:/Users/Jinhyuk/Documents")   #working directory ����

#-------���� ������ �б�
weather.data <- read.csv("weather_data.csv")  #weather_data.csv ���� �б�
View(weather.data)
str(weather.data)

#-------���� ������ �б�
sales.data <- read.csv("sales_data.csv", na.strings=c("")) #sales_data.csv ���� �б�, ���� ����� ���� ���� NA�� ó��
sales.data$���� = as.character(sales.data$����) #������ factor�� ����Ǿ� �ֱ� ������ ���ڿ��� ����
sales.data$���� = as.integer(gsub(",", "", sales.data$����)) #���⿡ ',' ���ڸ� �������� ������ ��, ���������� Type ����
View(sales.data)        
str(sales.data)

#��¥�� factor�� �����Ǿ�� �ұ�? ���ڿ��� ���� �Ǿ�� �ұ�?
#-------���� ���� ������ ����
weather.sales.data <- weather.data
weather.sales.data$���� <- as.integer(sales.data$����) #weather.sales.data �� ����, ���� ������ ����
str(weather.sales.data)
View(weather.sales.data)


#-------��� ���� -----------
article.data <- read.csv("article_data.csv") #article_data.csv ���� �б�  -> ��� �������� ���� ���� ũ�Ⱑ Ŀ�� ������ ����� �� �о�� -> ������ �߿����� �ʱ� ������ ����
article.count <- table(article.data$��¥, article.data$�з�)   #��¥�� ���� ������, ��ȸ�� ��� ����
article.count <- as.data.frame.matrix(article.count)  #table -> dataframe ��ȯ
article.count <- data.frame(���� = c(NA, article.count[,1]),��ȸ = c(NA, article.count[,2])) #2013�� 1�� 1�� �Ź� ��� ������ �ȵǱ� ������ �� �� ��� ���� NA�� ����
article.count
weather.sales.article.data <- weather.sales.data    #��� �� �߰��� dataframe ����
weather.sales.article.data$�������� <- article.count$���� #���� ��� �� �߰�
weather.sales.article.data$��ȸ���� <- article.count$��ȸ #��ȸ ��� �� �߰�
weather.sales.article.data$�ѱ��� <- rowSums(article.count[,1:2], na.rm = TRUE) #�� ��� �� �߰�
View(weather.sales.article.data)
str(weather.sales.article.data)

#-------�� ��-----------
View(weather.sales.article.data)
cor(weather.sales.article.data[,3:13] , use = "pairwise.complete.obs") # �� column�� ���� ����м�
m <- lm(���� ~ ��������+��ȸ����, weather.sales.article.data)
summary(m)


#����м��� ���� ���� ���� ������ �ʴ´�.


m <- lm(���� ~ �ѱ���, weather.sales.article.data)#������ ���� ���� ȸ�� �м�
summary(m)
#���� ���� ������ �ʴ´�.

#������ ����
#------���� �߰�----
season.data <- c()
season.data[grep('201.-(12|01|02)-',weather.sales.article.data$��¥)] <- '�ܿ�' #1, 2, 12���� �ش��ϴ� �ε����� �ܿ� ����
season.data[grep('201.-(03|04|05)-',weather.sales.article.data$��¥)] <- '��'   #3, 4, 5���� ��
season.data[grep('201.-(06|07|08)-',weather.sales.article.data$��¥)] <- '����'
season.data[grep('201.-(09|10|11)-',weather.sales.article.data$��¥)] <- '����'

w.s.a.s.data <- weather.sales.article.data 
w.s.a.s.data$���� <- as.factor(season.data) #���� column �߰�
View(w.s.a.s.data)
str(w.s.a.s.data)

#-----���, ���� ������ ����ȭ-----
#----���� ���� ������� �µ��� ���Ѵ�.
relativeTemp <- c()
calcTemp <- function(){
  for(year in 2013:2015){    #2013����� 2015��     
    for(month in 1:12){       #1������ 9��
      if(year == 2015 && month == 9){ #2015���� 8������ �����Ͱ� �����ϹǷ� �ݺ��� ����
        break;
      }
      regex <- paste(as.character(year),'-',sep='')     #���Խ� �����
      if(month < 10){
        regex <- paste(regex, as.character(month), sep='0')
      }
      else{
        regex <- paste(regex, as.character(month), sep='')
      }
      temperature.mean <- mean(w.s.a.s.data$���[grep(regex, w.s.a.s.data$��¥)])   #���� ��� ���
      season <- w.s.a.s.data$����[grep(regex, w.s.a.s.data$��¥)[1]]    #��� �������� ����
      if(season == '�ܿ�' || season == '����'){#�ܿ�, ���� ��տµ� - ����µ�
        relativeTemp <<- c(relativeTemp, w.s.a.s.data$���[grep(regex, w.s.a.s.data$��¥)]-temperature.mean)
      }
      else{   #����, ������ ����µ� - ��տµ�
        relativeTemp <<- c(relativeTemp, temperature.mean- w.s.a.s.data$���[grep(regex, w.s.a.s.data$��¥)])
      }
    }
  }
}
calcTemp()
relativeTemp #������ ���� ���� ������� �µ�
relativeTemp.data.frame <- w.s.a.s.data  #������ ����
relativeTemp.data.frame$���µ� <- relativeTemp #���´� Column �߰�
View(relativeTemp.data.frame)

cor(relativeTemp.data.frame[,c(3:13,15)] , use = "pairwise.complete.obs")


#----- ���µ��� ����ȭ
normalization <- function(x){
  temp <- (x - mean(x, na.rm= TRUE))/sd(x, na.rm = TRUE)
  return(temp)
}
relativeTemp.normal <- c()

calcTemp.normal <- function(){
  for(year in 2013:2015){    #2013����� 2015��     
    for(month in 1:12){       #1������ 9��
      if(year == 2015 && month == 9){ #2015���� 8������ �����Ͱ� �����ϹǷ� �ݺ��� ����
        break;
      }
      regex <- paste(as.character(year),'-',sep='')     #���Խ� �����
      if(month < 10){
        regex <- paste(regex, as.character(month), sep='0')
      }
      else{
        regex <- paste(regex, as.character(month), sep='')
      }
      print(regex)
      temperature.mean <- mean(w.s.a.s.data$���[grep(regex, w.s.a.s.data$��¥)])   #���� ��� ���
      season <- w.s.a.s.data$����[grep(regex, w.s.a.s.data$��¥)[1]]    #��� �������� ����
      if(season == '�ܿ�' || season == '����'){#�ܿ�, ���� ��տµ� - ����µ�
        relativeTemp.normal <<- c(relativeTemp.normal, normalization(w.s.a.s.data$���[grep(regex, w.s.a.s.data$��¥)]-temperature.mean))
      }
      else{   #����, ������ ����µ� - ��տµ�
        relativeTemp.normal <<- c(relativeTemp.normal, normalization(temperature.mean- w.s.a.s.data$���[grep(regex, w.s.a.s.data$��¥)]))
      }
    }
  }
}
calcTemp.normal()
relativeTemp.normal.data.frame <-relativeTemp.data.frame 
relativeTemp.normal.data.frame$���µ�.����ȭ <- relativeTemp.normal
View(relativeTemp.normal.data.frame)
cor(relativeTemp.normal.data.frame[,c(3:13,15, 16)] , use = "pairwise.complete.obs")




#���� ���� ����ȭ
sales.normal <- c()
calcSales.normal <- function(){
  for(year in 2013:2015){    #2013����� 2015��     
    for(month in 1:12){       #1������ 9��
      if(year == 2015 && month == 9){ #2015���� 8������ �����Ͱ� �����ϹǷ� �ݺ��� ����
        break;
      }
      regex <- paste(as.character(year),'-',sep='')     #���Խ� �����
      if(month < 10){
        regex <- paste(regex, as.character(month), sep='0')
      }
      else{
        regex <- paste(regex, as.character(month), sep='')
      }
      sales.mean <- mean(w.s.a.s.data$����[grep(regex, w.s.a.s.data$��¥)], na.rm = TRUE)   #���� ��� ����
      sales.normal <<- c(sales.normal, normalization(w.s.a.s.data$����[grep(regex, w.s.a.s.data$��¥)]-sales.mean))#���� ��� ���� - ���� ���� -> ����ȭ
    }
  }
}
calcSales.normal()
sales.normal
dst.data.frame <- relativeTemp.normal.data.frame
dst.data.frame$������.����ȭ <- sales.normal   #���� dataframe ����
View(dst.data.frame)
cor(dst.data.frame[,c(3:13,15, 16, 17)] , use = "pairwise.complete.obs")
plot(dst.data.frame$���µ�.����ȭ, dst.data.frame$������.����ȭ)


#���� ����ȭ
#����ȭ�� ���⿡�� -0.5 ���ϴ� ���ȸ���, 0.5�̻��̸� �� �ȸ���
sales.grade <- c()
sales.grade[dst.data.frame$������.����ȭ > 0.5] <- '���'
sales.grade[dst.data.frame$������.����ȭ < -0.5] <- '�ʹ�'
sales.grade <- ifelse(is.na(sales.grade), '�߹�', sales.grade) 
sales.grade <- ifelse(is.na(dst.data.frame$������.����ȭ), NA, sales.grade)
dst.data.frame$��� <- as.factor(sales.grade)

View(dst.data.frame)
str(dst.data.frame)
write.csv(dst.data.frame, 'dst.csv')
#------------ȸ�� �м�
library(mlbench)
View(dst.data.frame)
obj.view <- subset(dst.data.frame, select = c(����, ������, �ϻ緮, ������, ���, ǳ��, ���, ��������, ��ȸ����, �ѱ���, ���µ�, ���µ�.����ȭ, ������.����ȭ))
obj.view <- subset(dst.data.frame, select = c(����, ������, �ϻ緮, ������, ǳ��, ���, ��������, ��ȸ����, �ѱ���, ���µ�.����ȭ, ������.����ȭ))

m <- lm(������.����ȭ ~., data = obj.view)
m2 <- step(m, direction = "both")
summary(m2)     #������ ���������� �������� -> ������, �ϻ緮, ���, ǳ��, ���, ��ȸ����, ���µ�.����ȭ
m <- lm(������.����ȭ ~������ + �ϻ緮 + ǳ�� + ���µ�.����ȭ, data = obj.view)
summary(m)
#----------�з� ��
#---------�ǻ��������
library(party)
library(e1071)
library(nnet)
obj.view <- subset(dst.data.frame, select = c(������, �ϻ緮, ǳ��, ���µ�.����ȭ, ���))
obj.view <- obj.view[complete.cases(obj.view),]

index <- sample(2, nrow(obj.view), replace = TRUE, prob = c(0.7, 0.3))
data.train <- obj.view[index==1,]
data.test <- obj.view[index==2,]
tree <- ctree(���~., data = data.train)
pred <- predict(tree, data.test)
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)


nb <- naiveBayes(��� ~ ., data = data.train)
pred <- predict(nb, data.test)
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)

nn <- nnet(��� ~ ., data = data.train, size = 3)
pred <- predict(nn, newdata = data.test, type = "class")
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)

obj.view <- subset(dst.data.frame, select = c(������, �ϻ緮, ���, ǳ��, ���, ��ȸ����, ���µ�.����ȭ, ������.����ȭ))
obj.view <- obj.view[complete.cases(obj.view),]
index <- sample(2, nrow(obj.view), replace = TRUE, prob = c(0.7, 0.3))
data.train <- obj.view[index==1,]
data.test <- obj.view[index==2,]
mm <- lm(������.����ȭ ~ ., data = data.train)
pred <- predict(mm, newdata = data.test)
pred


#------���� ���� ������ �м�-----
#�ܿ�
select.column <- c("����", "����", "������", "�ϻ緮", "������", "ǳ��", "���", "����", "��������", "��ȸ����", "�ѱ���", "����", "���µ�.����ȭ", "����","�ڽ���","�̻�ġ", "������", "����", "������簳��", "������簳��", "�������ֺ���", "�������ֺ���", "��", "����", "�ϱ⿹��")
obj.view <- subset(dst.data.frame, ���� == '�ܿ�', select = select.column)
obj.view <- subset(obj.view, select = c("����", "����", "������", "�ϻ緮", "������", "ǳ��", "���", "����", "��������", "��ȸ����", "�ѱ���", "���µ�.����ȭ", "����","�ڽ���","�̻�ġ", "������", "����", "������簳��", "������簳��", "�������ֺ���", "�������ֺ���", "��", "����", "�ϱ⿹��"))
View(obj.view)
m <- lm(���� ~., data = obj.view,  use = "pairwise.complete.obs")
mm <- step(m, direction = "both")
summary(mm)
View(obj.view)

data.test.temp <- data.test[,!(names(data.test) %in% drops)]

  obj.view <- subset(dst.data.frame, ���� == '�ܿ�', select = select.column)
  drops <- c("����")
  obj.view <- obj.view[, !(names(obj.view) %in% drops)]
  cc <- complete.cases(obj.view)  #NA�� ���� �ε��� ���������� ����
  obj.view <- obj.view[cc, ] #NA�� ���� �� ����
  index <- sample(2, nrow(obj.view), replace = TRUE, prob = c(0, 1))
  data.test <- obj.view[index==2,]
  drops <- c("����")
  data.test.temp <- data.test[,!(names(data.test) %in% drops)]
  result <- predict(mm, newdata = data.test.temp)
  data.test$������� <- result
  temp <- subset(data.test, select = c(����, �������))
  hit_rate <- (nrow(temp[abs(temp$���� - temp$�������)<= 500000,])/nrow(temp))*100
  print(hit_rate)
  

View(temp)



obj.view <- subset(dst.data.frame, ���� == '�ܿ�', select = c(������, ��ȸ����, ���µ�.����ȭ, �ϻ緮, ���))
obj.view <- obj.view[complete.cases(obj.view),]

index <- sample(2, nrow(obj.view), replace = TRUE, prob = c(0.7, 0.3))
data.train <- obj.view[index==1,]
data.test <- obj.view[index==2,]
tree <- ctree(���~., data = data.train)
pred <- predict(tree, data.test)
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)


nb <- naiveBayes(��� ~ ., data = data.train)
pred <- predict(nb, data.test)
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)

nn <- nnet(��� ~ ., data = data.train, size = 3)
pred <- predict(nn, newdata = data.test, type = "class")
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)

#��
obj.view <- subset(dst.data.frame, ���� == '��', select = c(����, ������, �ϻ緮, ������, ǳ��, ���, ��������, ��ȸ����, �ѱ���, ���µ�.����ȭ, ������.����ȭ))
m <- lm(������.����ȭ ~., data = obj.view)
mm <- step(m, direction = "both")
summary(mm)
View(obj.view)


obj.view <- subset(dst.data.frame, ���� == '��', select = c(������, ������, ��������, ��ȸ����, ���µ�.����ȭ, ���))
obj.view <- obj.view[complete.cases(obj.view),]

index <- sample(2, nrow(obj.view), replace = TRUE, prob = c(0.7, 0.3))
data.train <- obj.view[index==1,]
data.test <- obj.view[index==2,]
tree <- ctree(���~., data = data.train)
pred <- predict(tree, data.test)
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)


nb <- naiveBayes(��� ~ ., data = data.train)
pred <- predict(nb, data.test)
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)

nn <- nnet(��� ~ ., data = data.train, size = 3)
pred <- predict(nn, newdata = data.test, type = "class")
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)

#����
obj.view <- subset(dst.data.frame, ���� == '����', select = c(����, ������, �ϻ緮, ������, ǳ��, ���, ��������, ��ȸ����, �ѱ���, ���µ�.����ȭ, ������.����ȭ))
m <- lm(������.����ȭ ~., data = obj.view)
mm <- step(m, direction = "both")
summary(mm)
View(obj.view)


obj.view <- subset(dst.data.frame, ���� == '����', select = c(������, �ϻ緮, ������, ���, ��ȸ����, ���µ�.����ȭ, ���))
obj.view <- obj.view[complete.cases(obj.view),]

index <- sample(2, nrow(obj.view), replace = TRUE, prob = c(0.7, 0.3))
data.train <- obj.view[index==1,]
data.test <- obj.view[index==2,]
tree <- ctree(���~., data = data.train)
pred <- predict(tree, data.test)
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)


nb <- naiveBayes(��� ~ ., data = data.train)
pred <- predict(nb, data.test)
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)

nn <- nnet(��� ~ ., data = data.train, size = 3)
pred <- predict(nn, newdata = data.test, type = "class")
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)

#����
obj.view <- subset(dst.data.frame, ���� == '����', select = c(����, ������, �ϻ緮, ������, ǳ��, ���, ��������, ��ȸ����, �ѱ���, ���µ�.����ȭ, ������.����ȭ))
m <- lm(������.����ȭ ~., data = obj.view)
mm <- step(m, direction = "both")
summary(mm)
View(obj.view)


obj.view <- subset(dst.data.frame, ���� == '����', select = c(���, ��ȸ����, ���µ�.����ȭ, ���))
obj.view <- obj.view[complete.cases(obj.view),]

index <- sample(2, nrow(obj.view), replace = TRUE, prob = c(0.7, 0.3))
data.train <- obj.view[index==1,]
data.test <- obj.view[index==2,]
tree <- ctree(���~., data = data.train)
pred <- predict(tree, data.test)
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)


nb <- naiveBayes(��� ~ ., data = data.train)
pred <- predict(nb, data.test)
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)

nn <- nnet(��� ~ ., data = data.train, size = 3)
pred <- predict(nn, newdata = data.test, type = "class")
conf.mat <- table(pred, data.test$���)
conf.mat
(accuracy <- sum(diag(conf.mat))/sum(conf.mat) * 100)

#-----�ְ� ���� �߰�
clothes.data <- read.csv("clothes.csv")   #���� �ְ� �б�
dst.data.frame$���� <- clothes.data$�ð�����  #column �߰�
View(dst.data.frame)

kospi.data <- read.csv("kospi.csv")  #�ð������� factor�� ����Ǿ� ����.
kospi.data$�ð����� <- as.character(kospi.data$�ð�����)
kospi.data$�ð����� <- as.numeric(gsub(",", "", kospi.data$�ð�����))
dst.data.frame$�ڽ��� <- as.numeric(kospi.data$�ð�����)

#----- ������ �߰�
holiday.data <- read.csv("holiday.csv")
str(holiday.data)

dst.data.frame$������ <- holiday.data$������
dst.data.frame$���� <- holiday.data$bh_bigtosmall

View(dst.data.frame)


#---------- ��� �����Ǵ� ������ �߰�-----
#---- ����, ���� ��� ����
article_sentiment_count <- read.csv("article_sentiment.csv")
colnames(article_sentiment_count) <- c('��¥', '�з�', '�������ְ���', '�������ְ���', '�߸����ְ���')
View(article_sentiment_count)
posi.article.count <- c()
nega.article.count <- c()
calcSentiArticle <- function(){
  for(year in 2013:2015){
    for(month in 1:12){
      for(day in 1:31){
        if(year == 2015 && month > 8){
          break
        }
        regex <- paste(as.character(year),'-',sep='')
        if(month < 10){
          regex <- paste(regex,as.character(month),sep = '0')
        }
        else{
          regex <- paste(regex,as.character(month),sep = '')
        }
        regex <- paste(regex, '-', sep='')
        if(day < 10){
          regex <- paste(regex, as.character(day), sep = '0')
        }
        else{
          regex <- paste(regex, as.character(day), sep = '')
        }
        tmp <- article_sentiment_count[grep(regex, article_sentiment_count$��¥),] #��¥���� ����
        if(nrow(tmp) == 0){
          print(regex)
        }
        else{
          posi.article.count <<- c(posi.article.count, nrow(tmp[tmp$�������ְ��� > tmp$�������ְ���,]))
          nega.article.count <<- c(nega.article.count, nrow(tmp[tmp$�������ְ��� <= tmp$�������ְ���,]))
        }
      }
    }
  }
}
calcSentiArticle()
posi.article.count <- c(0, posi.article.count)
nega.article.count <- c(0, nega.article.count)

dst.data.frame$������簳�� <- posi.article.count
dst.data.frame$������簳�� <- nega.article.count
View(dst.data.frame)
#----����, ���� ���� ����
sentiword.rate <- read.csv("sentiword_rate.csv")
View(sentiword.rate)

dst.data.frame$�������ֺ��� <- sentiword.rate$��������
dst.data.frame$�������ֺ��� <- sentiword.rate$��������
View(dst.data.frame)

#------�ڽ��� ���� �� �ֱ�
kosdaq.data <- read.csv('kosdaq.csv')
View(kosdaq.data)
dst.kosdaq.data <- c()
setKOSDAQ <- function(){
  for(date in 1:nrow(dst.data.frame)){
    index <- grep(dst.data.frame$��¥[date], kosdaq.data$����)
    tmp <- kosdaq.data[index,]
    if(nrow(tmp) == 0){
      dst.kosdaq.data <<- c(dst.kosdaq.data, dst.kosdaq.data[date-1])
    }
    else{
      dst.kosdaq.data <<- c(dst.kosdaq.data, kosdaq.data$�ð�����[index])
    }
  }
}
setKOSDAQ()
dst.kosdaq.data
dst.data.frame$�ڽ��� <- dst.kosdaq.data
#-------��¥ ������
day2 <- c();
abstractDay <- c();
setDay <- function(){
  for(year in 2013:2015){
    for(month in 1:12){
      for(day in 1:31){
        if(year == 2015 && month > 8){
          break
        }
        regex <- paste(as.character(year),'-',sep='')
        if(month < 10){
          regex <- paste(regex,as.character(month),sep = '0')
        }
        else{
          regex <- paste(regex,as.character(month),sep = '')
        }
        regex <- paste(regex, '-', sep='')
        if(day < 10){
          regex <- paste(regex, as.character(day), sep = '0')
        }
        else{
          regex <- paste(regex, as.character(day), sep = '')
        }
        if(nrow(dst.data.frame[grep(regex, dst.data.frame$��¥),]) == 0){
          print(regex)
        }
        else{
          day2 <<- c(day2, day)
          if(day <= 10){
            abstractDay <<- c(abstractDay, '�ʼ�')
          }
          else if(day <= 20){
            abstractDay <<- c(abstractDay, '�߼�')
          }
          else{
            abstractDay <<- c(abstractDay, '�ϼ�')
          }
        }
      }
    }
  }
}

setDay()
day2 
abstractDay
dst.data.frame$�� <- day2
dst.data.frame$���� <- as.factor(abstractDay)
View(dst.data.frame)
str(dst.data.frame)
#--------- ���� �ϱ� ���� ----
#������ �Ϸ羿 �����
prev.precipitation <- dst.data.frame$������
prev.precipitation <- c(prev.precipitation , 0)
prev.precipitation <- prev.precipitation[-1]

dst.data.frame$�ϱ⿹�� <- prev.precipitation

#--------�̻��� ��
abnormalDate <- read.csv('abnormal_date.csv')

dst.data.frame$�̻�ġ <- abnormalDate$�̻�ġ�����

View(dst.data.frame)

#------------ �� ���� -------
select.column <- c("����", "����", "������", "�ϻ緮","�̻�ġ", "������", "ǳ��", "���", "����", "��������", "��ȸ����", "�ѱ���", "����", "���µ�.����ȭ", "����","�ڽ���", "������", "����", "������簳��", "������簳��", "�������ֺ���", "�������ֺ���", "��", "����", "�ϱ⿹��")
obj.view <- subset(dst.data.frame, select = select.column)
m <- lm(���� ~., data = obj.view,  use = "pairwise.complete.obs")
m2 <- step(m , direction = "both")
summary(m2)

#-- �м��۾�
while(TRUE){
  obj.view <- subset(dst.data.frame, select = select.column)
  cc <- complete.cases(obj.view)  #NA�� ���� �ε��� ���������� ����
  obj.view <- obj.view[cc, ] #NA�� ���� �� ����
  index <- sample(2, nrow(obj.view), replace = TRUE, prob = c(0.9, 0.1))
  data.test <- obj.view[index==2,]
  drops <- c("����")
  data.test.temp <- data.test[,!(names(data.test) %in% drops)]
  result <- predict(m2, newdata = data.test.temp)
  data.test$������� <- result
  temp <- subset(data.test, select = c(����, �������))
  hit_rate <- (nrow(temp[abs(temp$���� - temp$�������)<= 600000,])/nrow(temp))*100
  print(hit_rate)
  if(hit_rate>=70){
    break
  }
}
#-------- ��ü ����
obj.view <- subset(dst.data.frame, select = select.column)
cc <- complete.cases(obj.view)  #NA�� ���� �ε��� ���������� ����
obj.view <- obj.view[cc, ] #NA�� ���� �� ����
index <- sample(2, nrow(obj.view), replace = TRUE, prob = c(0, 1))
data.test <- obj.view[index==2,]
drops <- c("����")
data.test.temp <- data.test[,!(names(data.test) %in% drops)]
result <- predict(m2, newdata = data.test.temp)
data.test$������� <- result
temp <- subset(data.test, select = c(����, �������))


#-------------plotting----------
#�� �׷���
View(temp)
nrow(temp)
write.csv(dst.data.frame, 'dst_data_frame.csv')
write.csv(temp, 'predict.csv')
temp <- read.csv('predict.csv')
temp$id <- seq(1, nrow(temp), 1)

plot(x = temp$id, y = temp$����, ylab = "�����", xlab ="����",type="o", cex = 1, col = "#FF0000")    #����� ���
legend("topright", legend=c("����"), pch = c(20), col = c("red"))

plot(x = temp$id, y = temp$�������, ylab = "�����", xlab ="����",type="o", cex = 1, col = "#0000FF")    #����� ���
legend("topright", legend=c("�������"), pch = c(20), col = c("blue"))

points(x = temp$id, y = temp$�������, type = "o", cex = 1, col = "#0000FF")  #
legend("topright", legend=c("����", "�������"), pch = c(20, 20), col = c("red", "blue"))


#box plot
box.data <- data.frame(���� = c(temp$����, temp$�������))
box.data$����[1:nrow(temp)] <- '��¥'
box.data$����[(nrow(temp)+1):nrow(box.data)] <- '����'
box.data$���� <- as.factor(box.data$����)
boxstats <- boxplot(���� ~ ����, data = box.data, ylab = "�����", notch = TRUE)
boxstats


#bar plot
barplot

#-------�����ֱ��
View(subset(dst.data.frame, select = c(��¥, �ڽ���, �ڽ���, ����)))
View(subset(dst.data.frame, select = c(��¥, ���, ����, ���µ�, ���µ�.����ȭ)))

View(subset(dst.data.frame, select = c(��¥, ����, ������.����ȭ, ���)))
View(subset(dst.data.frame, select = c(��¥, ����, ������, �̻�ġ)))
View(dst.data.frame)