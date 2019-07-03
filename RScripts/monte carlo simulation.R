magnitude = function(x, y) {
  stopifnot(isTRUE(all.equal(length(x),length(y))))
  return (sqrt(x^2 + y^2))
}
library("plotrix")
monte.carlo.pi<-function(n,draw=FALSE)
{
  circle.points<-0
  square.points<-0
  x<-runif(n,-1,1)
  y<-runif(n,-1,1)
  for (i in 1:n)
  {
    #if ((x[i])^2 + (y[i])^2 <=1)
    if (magnitude(x[i],y[i])<=1)
    {
      circle.points<-circle.points+1
      square.points<-square.points+1
    } else
    {
      square.points<-square.points+1
    }
  }
  if (draw==TRUE)
  {
    plot.new()
    frame()
    plot(x,y,asp=1,xlim=c(-1,1),ylim=c(-1,1))
    draw.circle(0,0,1,nv=1000,border=NULL,col=NA,lty=1,lwd=1)
    rect(-1,-1,1,1)
    return(4*circle.points / square.points)
  }
}

monte.carlo.pi(10, TRUE)