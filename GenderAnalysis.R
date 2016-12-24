install.packages("devtools", repos="https://ftp.iitm.ac.in/cran/")
library(devtools)
install_github("pablobarbera/Rfacebook", "pablobarbera", subdir="Rfacebook")
require("Rfacebook")
fb_oauth <- fbOAuth(app_id="359437864419569", app_secret="0d0437964d5a088ee6a880ca524517f7",extended_permissions = TRUE)
save(fb_oauth, file="fb_oauth")
load("fb_oauth")
posts <- getNewsfeed(token=fb_oauth, n=5)
print("test")
me <- getUsers("me",token=fb_oauth)
my_likes <- getLikes(user="me", token=fb_oauth)
#print(my_likes)
#print(me$username)

page_name <- "justclimateaction"
#page <- getPage(page_name, fb_oauth, n = 50, feed = FALSE)
#posts <- page$id

data_frame_gender <- data.frame(post=character(),male=numeric(),female=numeric(),etc=numeric(),likes=numeric(),type=character(),stringsAsFactors=FALSE)

for(i in 1:length(posts))
    {
	  print(paste0("loop-start: ", i))
      temp <- posts[i]
      #dataframe values:
      #post id
      #likes count
      #
      post <- getPost(temp,fb_oauth)
     
      data_frame_gender[i,1] <- post$post$message
      data_frame_gender[i,5] <- post$post$likes
      data_frame_gender[i,6] <- post$post$type
     
      gender_frame <- data.frame(gender=character(),stringsAsFactors=FALSE)
     
      for(j in 1:length(post$likes$from_id))
      {
		print(paste0("loop-mid: ", j))
        likes <- post$likes$from_id
        user_id <- likes[j]
       
        user <- getUsers(user_id,token=fb_oauth)
       
        gender <- user$gender
       
        gender_frame[nrow(gender_frame)+1,] <- gender
       
      }
     
	  print(paste("out of loop-mid: ", i))
      number_males <- nrow(subset(gender_frame, gender=="male"))
      number_females <- nrow(subset(gender_frame, gender=="female"))
      number_etc <- data_frame_gender[i,5] - (number_males+number_females)
     
      data_frame_gender[i,2] <- number_males
      data_frame_gender[i,3] <- number_females
      data_frame_gender[i,4] <- number_etc

	  print(paste0("loop-end: ", i))
     
    }


print(paste0("Males: ", sum(data_frame_gender$male)))
print(paste0("Females: ", sum(data_frame_gender$female)))
slices <- c(sum(data_frame_gender$male),sum(data_frame_gender$female),sum(data_frame_gender$etc))
 
pct <- round(slices/sum(slices)*100)
 lbls <- names(data_frame_gender[2:4])
 lbls <- paste(lbls, pct) # add percents to labels
 lbls <- paste(lbls,"%",sep="") # ad % to labels
 
 pie(slices, labels = lbls, main="Gender Distribution of all analyzed posts")
