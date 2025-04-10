a<-60
b<-55
if(a<b){
        print("b is greater than a")
    
    }else 
    {
        print("a is greater than b")
    }


x<-100
y<-100

if(x<y){
    print("y is greater than x")
    
}else if(y>x)
 {
     ("x is greater than y")
  }else
     {
         print("x=y")
     }



ifelse(a > b, "True", "false")

Marks<-93
outcome <- ifelse (Marks > 50, "Passed", "Failed")
print(outcome)


switch(5,"red","green","blue","yollow","white")



switch("ID", "Name" = "Tanzil", "dept" = "cse", "ID" = "22-47783-2")



i<-0
while(i<5)
    {
    i=i+1
    if(i==2){next}
    cat("value of i =",i,"\n")
    }


for (x in 1:5) {
    if (x %% 2 == 1) {
        print(x)
    }
}

for (x in 1:2) {

for (y in 1:3) {

print(x*y)

}

}


mystats <- function(x, parametric=TRUE, print=FALSE) {
  
  if (parametric) {
    center <- mean(x)
    spread <- sd(x)
  } else {
    center <- median(x)
    spread <- mad(x)
  }


  if (print) {
    if (parametric) {
      cat("Mean =", center, "\n", "Standard Deviation =", spread, "\n")
    } else {
      cat("Median =", center, "\n", "MAD =", spread, "\n")
    }
  }


  result <- list(center=center, spread=spread)
  return(result)
}


