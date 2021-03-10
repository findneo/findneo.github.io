---
title: 武汉大学C语言上机训练系统练习
date: 2016-08-20 08:15:01
description: 2016年8月初学编程时的训练。
---

> [WHU OJ ](http://acm.whu.edu.cn/starter/problem/list?volume=1)，已无法访问

![doing](whu_oj_doing.png)

![rank](whu_oj_rank.png)



### 1021乒乓球比赛

```c
#include<stdio.h>
int main()
{
    char i,j,k;
    for(i='X'; i<'X'+3; i++)
    {
        for(j='X'; j<'X'+3; j++)
        {
            for(k='X'; k<'X'+3; k++)
            {
                if(j!=i&&k!=i&&k!=j)
                {
                    printf("%c %c\n%c %c\n%c %c\n",'A',i,'B',j,'C',k);
                }
            }
        }
    }
    for(i='X'; i<'X'+3; i++)
    {
        for(j='X'; j<'X'+3; j++)
        {
            for(k='X'; k<'X'+3; k++)
            {
                if(j!=i&&k!=i&&k!=j)
                {
                    if(i=='X'||k=='X'||k=='Z')
                    {
                        continue;
                    }
                    else
                    {
                        printf("%c %c\n%c %c\n%c %c\n",'A',i,'B',j,'C',k);
                    }
                }
            }
        }
    }
    return 0;
}

```

### 1025计算时间

```c
#include<stdio.h>
#include<stdlib.h>
int time_elapse(int hour, int minute, int second)
{
    return hour*3600+minute*60+second;
}
int main()
{
    int n;
    char t[9],s[9];
    int a,b,c,d,e,f;
    int s1,s2;
    scanf("%d",&n);
    for(; n>0; n--)
    {
        while(getchar()!='\n');
        scanf("%s%s",t,s);
        a=t[0]*10+t[1]-528;
        b=t[3]*10+t[4]-528;
        c=t[6]*10+t[7]-528;
        d=s[0]*10+s[1]-528;
        e=s[3]*10+s[4]-528;
        f=s[6]*10+s[7]-528;
        s1=time_elapse(a,b,c);
        s2=time_elapse(d,e,f);
        printf("%d %d %d\n",s1,s2,(s1>s2?s1-s2:s2-s1));

    }
    return 0;
}

```

### 1026非递归斐波那契

```c
#include<stdio.h>
#include<stdlib.h>
int fibonacci(int n)
{
    int a,b;
    a=b=1;
    while(n-->1){
        b=b+a;
        a=b-a;
    }
    return b;
}
int main()
{
    int n,m;
    scanf("%d",&n);
    for(; n>0; n--)
    {
        scanf("%d",&m);
        printf("%d\n",fibonacci(m));

    }
    return 0;
}



/*
#include<iostream>
using namespace std;
int main(){
    int n, i, f1, f2;
    cin>>n;
    f1 = 0;
    f2 = 1;
    while(n-->1){
        f2 += f1;
        f1 = f2 - f1;
    }
    cout<<(n==-1?0:f2)<<endl;
}
*/
```

### 1028递归转换进制

```c
#include<stdio.h>
#include<stdlib.h>
//#define A 10
#define B 7
int change(int n)
{
    int temp;
    if(n<B)
    {
        printf("%d",n);
        return 0;
    }
    else
    {
        change(n/B);
        change(n%B);
    }
}
int main()
{
    int n,m;
    scanf("%d",&n);
    for(; n>0; n--)
    {
        scanf("%d",&m);
        change(m);
        printf("\n");

    }
    return 0;
}

```

### 1029求自然对数

```c
#include<stdio.h>
#include<stdlib.h>
int main()
{
    int i;
    double fenMu=1;
    double ans=1;
    for(i=1;fenMu-1e15<0;i++){
        fenMu*=i;
        ans+=1.0/fenMu;
    }
    printf("%.14lf\n",ans);
    return 0;
}

```

### 1030二次方程

```c
#include<stdio.h>
#include<stdlib.h>
#include<math.h>
int fangcheng(int a,int b,int c)
{
    double x1,x2,dal;
    if(a!=0)
    {
        if(b*b-4*a*c>0)
        {
            dal=pow(b*b-4*a*c,0.5);
            x1=(-b-dal)/(double)(2*a);
            x2=(-b+dal)/(double)(2*a);
            if(a<0)
            {
                dal=x1;
                x1=x2;
                x2=dal;
            }
            printf("%.2lf %.2lf",x1,x2);
            return 0;
        }
        else if(b*b-4*a*c==0)
        {
            if(b==0)
            {
                printf("0.00");
                return 0;
            }
            else
            {
                printf("%.2lf",-(double)b/(2*a));
                return 0;
            }
        }
        else
        {
            printf("NULL");
            return 0;
        }
    }

    else
    {
        if(b==0)
        {
            if(c==0)
            {
                printf("NULL");
                return 0;
            }
            else
            {
                printf("NULL");
                return 0;
            }
        }
        else
        {
            if(c==0)
            {
                printf("0.00");
                return 0;
            }
            else
            {
                printf("%.2lf",-c/(double)b);
                return 0;
            }
        }
    }
}
int main()
{
    int n,a,b,c,i;
    scanf("%d",&n);
    for(i=1; i<=n; i++)
    {
        scanf("%d%d%d",&a,&b,&c);
        printf("Case %d: ",i);
        fangcheng(a,b,c);
        printf("\n");
    }
    return 0;
}
```

### 1034十进制转二进制

```c
#include<stdio.h>
int main()
{
    int n,i,j;
    long long a;
    int b[33];
    scanf("%d",&n);
    for(i=0; i<n; i++)
    {
        scanf("%lld",&a);
        j=0;
        if(a==0){printf("%ld\n",a);continue;}
        while(a!=0)
        {
            b[j++]=a%2;
            a=a/2;
        }
        while(--j>=0){
            printf("%d",b[j]);
        }
        printf("\n");
    }

    return 0;
}
```

### 1035十进制转其他

```c
#include<stdio.h>
int main()
{
    int n,i,j,jidi;
    long long a;
    int b[33];
//    scanf("%d",&n);
    n=60000;
    printf("本程序提供2**32以下十进制正整数转任意36以内进制结果\
           \n输入(-1,-1)结束\n");
    printf("请每次输入两个数，前者作为基底，后者待转换\n");
    for(i=0; i<n; i++)
    {

        scanf("%d%lld",&jidi,&a);if(jidi==-1){break;}
        j=0;
        if(a==0){printf("%lld\n",a);continue;}
        while(a!=0)
        {
            b[j++]=a%jidi;
            a=a/jidi;
        }
        while(--j>=0){
                if(b[j]>9){printf("%c",'A'-10+b[j]);}
            else {printf("%d",b[j]);}
        }
        printf("\n");
    }

    return 0;
}

```

### 1036字符替换

```c
#include<stdio.h>
int substitute(char str[], char oldchar, char newchar)
{
    int time=0;
    int i=0;
    while(str[i]!='\0')
    {
        if(str[i]==oldchar)
        {
            str[i]=newchar;
            time++;
        }
        i++;
    }
    return time;
}
int main()
{
    char str[1001];
    char oldchar,newchar;
    while (scanf("%s %c %c", str, &oldchar, &newchar) == 3) /* 或!= EOF , 但前者更好 */

    {

        printf("%d ",substitute(str,oldchar,newchar));
        puts(str); //处理

    }
    return 0;
}

```

### 1037关键词统计

```c
#include<stdio.h>
#include<string.h>
int main()
{
    int i,j,k,n,times,flag;
    char str[10][11];
    char long_str[10001];
    scanf("%d",&n);
    for(i=0;i<n;i++){
        scanf("%s",str[i]);
    }
    scanf("%s",long_str);
    for(i=0;i<n;i++){
            times=0;
        for(j=0;j<strlen(long_str)-strlen(str[i])+1;){
            if(long_str[j]==str[i][0]){
                flag=0;
                for(k=0;k<strlen(str[i]);k++){
                    if(long_str[j+k]!=str[i][k]){
                        flag=1;break;
                    }
                }
                if(flag==1){j++;}
                else{
                    times++;j+=k;
                }
            }
            else{j++;}
        }
        printf("%d\n",times);
    }
    return 0;
}

```

### 1037学号查询

```c
#include<stdio.h>
#include<string.h>
struct student
{
    char name[32];
    char birth[9];
    char num[9];
    char major[32];
};
int main()
{
    struct student stu[30];
    int i,j,n;
    char num1[9];
    for(i=0;i<30;i++){
        scanf("%s %s %s %s",stu[i].name,stu[i].birth,stu[i].num,stu[i].major);
    }
    scanf("%d",&n);
    for(i=0;i<n;i++){
        scanf("%s",num1);
        for(j=0;j<30;j++){
            if(strcmp(stu[j].num,num1)==0){
               printf("%s %s %s %s\n",stu[j].name,stu[j].birth,stu[j].num,stu[j].major);
            break;
            }
        }
        if(j==30){
            printf("Not found\n");
        }
    }
}

```

### 1038插入排序

```c
#include<stdio.h>
#include<string.h>
int main()
{
    int nCase,i,j,k,temp;
    int n;
    int s[1000];
    scanf("%d",&nCase);
    for(i=0; i<nCase; i++)
    {
        scanf("%d",&n);
        for(j=0; j<n; j++)
        {
            scanf("%d",s+j);
        }
        for(j=0; j<n; j++)
        {
            temp=s[j];
            for(k=j-1; k>=0; k--)
            {
                if(s[k]>temp)
                {
                    s[k+1]=s[k];
                }
                else
                {
                    break;
                }
            }
            s[k+1]=temp;
        }
        for(j=0; j<n; j++)
        {
            printf("%d ",s[j]);
        }
        printf("\n");
    }

}

```

### 1042折半查找

```c
#include<stdio.h>
int data[20000];
int binary_search(int d[], int s, int e, int q)
{
    int mid;
    while(s<=e)
    {
        mid=(s+e)/2;
        if(d[mid]==q)
        {
            return mid;
        }
        else if(d[mid]<q){s=mid+1;}
        else{e=mid-1;}
    }
    return -1;
}
int main()
{
    int n,i,m,s,e,q;
    scanf("%d",&n);
    for(i=0; i<n; i++)
    {
        scanf("%d",data+i);
    }
    scanf("%d",&m);
    for(i=0; i<m; i++)
    {
        scanf("%d %d %d",&s,&e,&q);
        if(e>n){e=n;}
        if(s>n-1||s>e-1){printf("-1\n");continue;}
        printf("%d\n",binary_search(data,s,e-1,q));

    }
    return 0;
}

```

### 1043矩阵加法

```c
#include<stdio.h>
int main()
{
    int M,N,a[11][11],b[11][11];
    int i,j,flag,num;
    while(scanf("%d",&M)==1&&M!=0&&scanf("%d",&N)==1)
    {
        for(i=1; i<=M; i++)
        {
            for(j=1; j<=N; j++)
            {
                scanf("%d",&a[i][j]);
            }
        }
        for(i=1; i<=M; i++)
        {
            for(j=1; j<=N; j++)
            {
                scanf("%d",&b[i][j]);
            }
        }
        for(i=1; i<=M; i++)
        {
            for(j=1; j<=N; j++)
            {
                a[i][j]+=b[i][j];
            }
        }
        num=0;
        for(i=1; i<=M; i++)
        {
            flag=1;
            for(j=1; j<=N; j++)
            {
                if(a[i][j]!=0)
                {
                    flag=0;
                    break;
                }
            }
            if(flag==1)
            {
                num++;
            }
        }
        for(i=1; i<=N; i++)
        {
            flag=1;
            for(j=1; j<=M; j++)
            {
                if(a[j][i]!=0)
                {
                    flag=0;
                    break;
                }
            }
            if(flag==1)
            {
                num++;
            }
        }
        printf("%d\n",num);
    }
    return 0;
}

```

### 1044逗号加法

```c
#include<stdio.h>
int main()
{
    char a[20],b[20];
    long long A,B,temp;
    int i,j;
    while(scanf("%s %s",a,b)==2)
    {
        A=B=0;
        for(i=0; a[i]!='\0'; i++);
        j=-1;temp=1;
        while(--i>=0)
        {
            if(a[i]-'0'>-1&&a[i]-'0'<10)
            {
                j++;temp=10*temp;
                A+=(a[i]-'0')*temp/10;
            }
            if(a[i]==',')continue;
            if(a[i]=='-')A=-A;
        }
        for(i=0; b[i]!='\0'; i++);
        j=-1;temp=1;
        while(--i>=0)
        {
            if(b[i]-'0'>-1&&b[i]-'0'<10)
            {
                j++;temp=10*temp;
                B+=(b[i]-'0')*temp/10;
            }
            if(b[i]==',')continue;
            if(b[i]=='-')B=-B;
        }
        printf("%lld\n",A+B);
    }
    return 0;
}

```

### 1046统计字符

```c
#include<stdio.h>
int main()
{
    char a[7],na[7],b[1001];
    int i,j,k;
    while(fgets(a,7,stdin)&&a[0]!='#')
    {
        for(i=0; a[i]!='\0'; i++);
        for(j=0; j<7; j++)
        {
            na[j]=0;
        }
        fgets(b,1000,stdin);
        for(k=0; b[k]!='\0'; k++)
        {
            for(j=0; j<i; j++)
            {
                if(b[k]==a[j])
                {
                    na[j]++;
                }
            }
        }
        for(j=0; j<i-1; j++)
        {
            printf("%c %d\n",a[j],na[j]);
        }
    }
    return 0;
}

```

### 1048ZOJ

```c
#include<stdio.h>
int main()
{
    int z,o,j,i;
    z=o=j=0;
    char a[101];
    while(fgets(a,101,stdin)&&a[0]!='E'){
            for(i=0;a[i]!='\0';i++){
                if(a[i]=='Z'){z++;continue;}
        if(a[i]=='O'){o++;continue;}
        if(a[i]=='J'){j++;continue;}
            }
        while(1){
            if(z>0){printf("Z");z--;}
            if(o>0){printf("O");o--;}
            if(j>0){printf("J");j--;}
            if(z==0&&o==0&&j==0){break;}
        }
        printf("\n");z=o=j=0;
    }
    return 0;
}

```

### 1049不循环反转数组（递归）

```c
#include<stdio.h>
int a[100];
void reverse(i)
{
    if(i==1){scanf("%d",a+i);printf("%d ",a[i]);}
    else {
        scanf("%d",a+i);reverse(i-1);printf("%d ",a[i]);
    }
}
int main()
{
    int n,i;
    scanf("%d",&n);
    reverse(n);
    return 0;
}

```

### 1050百鸡问题

```c
#include<stdio.h>
int main()
{
   int x,y,z,n,i,j,k;
   while(scanf("%d",&n)==1&&n!=EOF){
    for(i=0;i<n/5+1;i++){
        for(j=0;j<(n-5*i)/3+1;j++){
            if(5*i+3*j+(100-i-j+2)/3<n+1){
                printf("x=%d,y=%d,z=%d\n",i,j,100-i-j);
            }
        }
    }
   }
    return 0;
}

```

### 1051折半查找'小于'临界点

```c
#include<stdio.h>
int data[20000];
int binary_search(int d[], int s, int e, int q)
{
   int s0=s,e0=e;
   int mid;
   if(d[s]>q-1){return 0;}
   if(d[e]<q){return e0-s0+1;}
   while(1){
    mid=(s+e)/2;
    if(d[mid]<q){
        if(d[mid+1]<q){s=mid+1;}
        else{return mid-s0+1;}
    }
    else if(d[mid]>q){e=mid-1;}
    else{e--;}
   }
}
int main()
{
    int n,i,m,s,e,q;
    scanf("%d",&n);
    for(i=0; i<n; i++)
    {
        scanf("%d",data+i);
    }
    scanf("%d",&m);
    for(i=0; i<m; i++)
    {
        scanf("%d %d %d",&s,&e,&q);
        if(s==n||s==e)
        {
            printf("-1\n");
            continue;
        }
        printf("%d\n",binary_search(data,s,e-1,q));

    }
    return 0;
}

```

### 1052全排列

```c
#include<stdio.h>
#include<string.h>
#define N 10
//#define D printf("m=%d\tproduct=%d\tstart=%d\ti=%d\tj=%d\tk=%d\tt=%d\n",m,product,start,i,j,k,t);
//#define M for(start=0;start<len;start++){printf("%d ",index[start]);}printf("\n");
void mySort(char* s)
{
    int len=strlen(s);
    int i,j;
    char temp;
    for(i=0;i<len;i++){
        for(j=i+1;j<len;j++){
            if(s[i]>s[j]){
                temp=s[i];s[i]=s[j];s[j]=temp;
            }
        }
    }
}
int main()
{
    char str[N+1],res[N+1],index[N+1];
    int m,i,j,k,t,product,len;
    int start;
    while(scanf("%s%d",str,&m)==2){
            len=strlen(str);
        mySort(str);
                                                                    //puts(str);
        for(i=0;i<len;i++){index[i]=i;}
        for(i=product=1;i<len+1;i++){
            product*=i;
            if(product>m){break;}
            }
        for(j=0;j<len-i;j++){
            res[j]=str[j];
            index[j]=-1;
        }
            //从后往前数第i个字母前的都是按全排列的第一个排列的顺序排列
                                                // printf("m=%d\tproduct=%d\ti=%d\n",m,product,i);
        while(j<len){
         product/=i;                            //D
         start=m/product;                       //D
         for(t=0;index[t]==-1&&t<len;t++);      //D

         for(k=t;start!=0;k++){
            if(index[k]!=-1){start--;}
            else{continue;}
         }
         while(index[k]==-1){k++;}               //printf("%d***%d***\n",k,index[k]);   D

         res[j]=str[k];
         index[k]=-1;
         m%=product;                              //  D M
         i--;j++;                             // printf("########################\n");
        }
        res[j]='\0';
        puts(res);
    }
    return 0;
}

```

### 1053画菱形

```c
#include<stdio.h>
int main()
{
    int n,i,j;
    while(scanf("%d",&n)==1){
        for(i=0 ;i<n+1;i++){
            for(j=0;j<2*n-2*i;j++){printf(" ");}
            for(j=0;j<4*i+1;j++){printf("*");}
            printf("\n");
        }
        for(i=n-1 ;i>-1;i--){
            for(j=0;j<2*n-2*i;j++){printf(" ");}
            for(j=0;j<4*i+1;j++){printf("*");}
            printf("\n");
        }
    }
    return 0;
}

```

### 1054冒泡排序交换次数

```c
#include<stdio.h>
int main()
{
    int n,i,j,a[1000],temp,t;
    while(scanf("%d",&n)==1&&n!=0){
        for(i=0 ;i<n;i++){
            scanf("%d",a+i);
        }
        for(i=0,t=0;i<n;i++){
            for(j=i+1;j<n;j++){
                if(a[j]<a[i]){temp=a[j];a[j]=a[i];a[i]=temp;t++;}
            }
        }
        printf("%d\n",t);

    }
    return 0;
}

```

### 1055凯撒密码+K

```c
#include<stdio.h>
int main()
{
   char a[100];
   int i,j;
   long k;
   while(scanf("%s",a)==1){
    scanf("%ld",&k);
    for(i=0;a[i]!='\0';i++){
        j=(k+i+1)%26;
        a[i]=(a[i]-'A'+26-j)%26+'A';
    }
    puts(a);
   }
    return 0;
}

```

### 1056大数相加

```c
#include<stdio.h>
#define N 1000+2
int main()
{
    int n,i,j,k,m,len1,len2,jinwei;
    char a[N],b[N],c[N];
    scanf("%d",&n);
    for(m=0;m<n;m++){
        scanf("%s%s",a,b);
        //向右对齐，左边补零
        for(j=0;a[j]!='\0';a[j]-='0',j++);
        for(len1=j+1;j>-1;a[j+N-len1]=a[j],j--);
        for(j=N-1-len1;j>-1;a[j]=0,j--);

        for(k=0;b[k]!='\0';b[k]-='0',k++);
        for(len2=k+1;k>-1;b[k+N-len2]=b[k],k--);
        for(k=N-1-len2;k>-1;b[k]=0,k--);
//相加
        jinwei=0;
        for(i=N-2;i>-1;i--){
            c[i]=(a[i]+b[i]+jinwei)%10;
            jinwei=(a[i]+b[i]+jinwei)/10;
        }
//输出
        for(i=0;c[i]==0&&i<N-1;i++);
        if(i==N-1){printf("0\n");continue;}//考虑输入为(0,0)的情况
        for(;i<N-1;i++){printf("%d",c[i]);}
        printf("\n");
    }
    return 0;
}

```

### 1057二分法解方程浮点

```c
#include<stdio.h>
#include<math.h>
#define func(x) 2*x*x*x-4*x*x+3*x-6
int main()
{
    int i,flag;
    double y,x,hi,lo;
    while(scanf("%lf",&y)==1)
    {
        flag=0;
        hi=10000;
        lo=-10000;
        if(func(lo)-y>0||func(hi)-y<0)
        {
            printf("NULL\n");continue;
        }
        while(!(fabs(lo-hi)<0.000001))
        {
            x=(hi+lo)/2.0;
            if(func(x)-y>0)
            {
                hi=x;
            }
            else if(func(x)-y<0)
            {
                lo=x;
            }
        }
        printf("%.4lf\n",x);
    }
    return 0;
}

```

### 1058小试指针

```c
#include<stdio.h>
int main()
{
    int arr[10]={1,3,5,7,9,11,13,15,17,19};
    int *pt=arr;
  // int *a,*b,*c,*d;
    //a=b=c=d=arr;
    printf("%p\n%p\n%p\n%d\n",&arr[0],&pt,pt,*pt);
    printf("%d\n",*pt+3);
    printf("%d\n",pt[3]);
    printf("%p\n",&*pt);
    printf("%p\n",*&pt);
    //printf("%d\n",*pt[3]);
    printf("%d\n",*(pt+3));
    printf("%d\n",*pt++);
    printf("%d\n",*(pt++));
    printf("%d\n",(*pt)++);
    printf("%d\n",++(*pt));
    return 0;
}

```

### 1060转置矩阵

```c
#include<stdio.h>
#include<stdlib.h>
int main()
{
    int m,n,i,j;
    int *p;
    while(scanf("%d%d",&m,&n)==2){
        p=(int*)malloc(sizeof(int)*m*n);
        for(i=0;i<m;i++){
            for(j=0;j<n;j++){
                scanf("%d",p+i*n+j);
            }
        }
        for(i=0;i<n;i++){
            for(j=0;j<m;j++){
                printf("%d ",*(p+j*n+i));
            }
            printf("\n");
        }
        free(p);
    }
}

```

### 1061成绩查询

```c
#include<stdio.h>
#include<math.h>
#define N 10
struct student
{
    int id;
    int score;
};
void findmax(struct student *stu, int *score, int *index)
{
    int i;
    *score=(*stu).score;
    *index=0;
    for(i=0; i<N; i++)
    {
        if(*score<(*(stu+i)).score)
        {
            *score=(*(stu+i)).score;
            *index=i;
        }
    }
}
void findmin(struct student *stu, int *score, int *index)
{
    int i;
    *score=(*stu).score;
    *index=0;
    for(i=0; i<N; i++)
    {
        if(*score>(*(stu+i)).score)
        {
            *score=(*(stu+i)).score;
            *index=i;
        }
    }
}
void findaver(struct student *stu, int *score, int *index)
{
    int sum,i;
    int delta,delta_min;
    for(i=sum=0; i<N; i++)
    {
        sum+=(*(stu+i)).score;
    }
    *score=(*stu).score;
    *index=0;
    delta_min=fabs((*stu).score*N-sum);
    for(i=0; i<N; i++)
    {
        delta=fabs((*(stu+i)).score*N-sum);
        if(delta<delta_min)
        {
            delta_min=delta;
            *score=(*(stu+i)).score;
            *index=i;
        }
    }
}
int main()
{
    struct student *stu=(struct student*)malloc(sizeof(struct student)*N);
    int i;
    int score,index;
    for(i=0; i<N; i++)
    {
        scanf("%d %d",&((*(stu+i)).id),&((*(stu+i)).score));
    }
    findmax(stu,&score,&index);
    printf("%d %d\n",(*(stu+index)).id,score);
    findmin(stu,&score,&index);
    printf("%d %d\n",(*(stu+index)).id,score);
    findaver(stu,&score,&index);
    printf("%d %d\n",(*(stu+index)).id,score);
    free(stu);
    return 0;
}

```

### 1063查找子字符串

```c
#include<stdio.h>
#include<stdlib.h>
char *findstr(char *s, char *t)
{
    int i,j,flag;
    for(i=0; *(s+i)!='\0'; i++)
    {
        if(*(s+i)==*t)
        {
            flag=1;
            for(j=1; *(t+j)!='\0'; j++)
            {
                if(*(s+i+j)!=*(t+j))
                {
                    flag=0;
                    break;
                }
            }
            if(flag==1)
            {
                return s+i;
            }
        }
    }
    return NULL;
}
int main()
{
    char *s=(char*)malloc(sizeof(char)*1001);
    char *t=(char*)malloc(sizeof(char)*1001);
    while(scanf("%s%s",s,t)==2)
    {
        printf("%p %p\n",s,findstr(s,t));
    }
    return 0;
}

```

### 1064队列操作

```c
#include<stdio.h>
#include<stdlib.h>
//#define D printf("front=%d\trear=%d\n",front,rear);
typedef int datatype;
int main()
{
    int n,m,op,id,front,rear;
    while(scanf("%d%d",&n,&m)==2){
            n++;
            datatype* a=(datatype*)malloc(sizeof(datatype)*(n));
            front=rear=0;
        while(m--){
            scanf("%d%d",&op,&id);
            if(1==op){
                if((rear+1)%n!=front){
                    a[rear]=id;
                    rear=(rear+1)%n;
                }                                         //  D
            }
            else if(2==op){
                if(rear!=front){
                    front=(front+1)%n;
                }                                          // D
            }else {continue;}
        }
        if(front==rear){printf("NULL\n");continue;}
       while(front!=rear){
        printf("%d ",a[front]);
        front=(front+1)%n;
       }printf("\n");
    }
    return 0;
}

```

### 1065栈操作

```c
#include<stdio.h>
#include<stdlib.h>
int *a;
int top;
int push(int vol,int id)
{
    if(top>vol-2)
    {
        return 1;
    }
    else
    {
        a[++top]=id;
        return 0;
    }
}
int pop(int vol)
{
    if(top==-1)
    {
        return 1;
    }
    else
    {
        top--;
        return 0;
    }
}
//int debug()
//{
//    int i=top;
//    printf("top=%d\t",top);
//    while(i>-1){
//        printf("%d ",a[i--]);
//    }
//    printf("\n");
//    return 0;
//}
int main()
{
    int n,m,op,id,i;
    while(scanf("%d%d",&n,&m)==2)
    {
        a=(int*)malloc(sizeof(int)*n);
        top=-1;
        while(m-->0)
        {
            scanf("%d%d",&op,&id);
            if(op==1)
            {
                push(n,id);
                //debug();
            }
            else if(op==2)
            {
                pop(n);
                //debug();
            }
            else
            {
                continue;
            }
        }
        if(top==-1){printf("NULL");}
        while(top>-1)
        {
            printf("%d ",a[top--]);
        }
        printf("\n");
        free(a);
    }
    return 0;
}

```

### 1066判断点是否在圆上

```c
#include<stdio.h>
#include<stdlib.h>
typedef struct
{
    double x;
    double y;
}POINT;
typedef struct
{
    double m;
    double n;
    double r;
}CIRCLE;
int in_circle(POINT p, CIRCLE c)
{
    double temp1=(p.x-c.m)*(p.x-c.m)+(p.y-c.n)*(p.y-c.n);
    double temp2=c.r*c.r;
   if(temp1-temp2>0){return 0;}
   else if(temp1-temp2<0){return 2;}
    else {return 1;}
}
int main()
{
    POINT p;
    CIRCLE c;
    while(scanf("%lf%lf%lf%lf%lf",&p.x,&p.y,&c.m,&c.n,&c.r)==5)
    {
        printf("%d\n",in_circle(p,c));
    }
    return 0;
}

```

### 1067字节输出

```c
#include<stdio.h>
union my_union
{
    int a;
    unsigned char b[sizeof(int)];
};
int main()
{
    int i;
    union my_union test;
    while(scanf("%d",&test.a)==1){
        for(i=0;i<sizeof(int);i++){
            printf("%.2X",test.b[i]);
        }printf("\n");
    }
    return 0;
}

```

### 1068链表基本操作

```c
#include<stdio.h>
#include<stdlib.h>
typedef struct NODE
{
    int val;
    struct NODE* next;
} node;
node *head;
int addNode(idx,val)
{
    node *p=head;
    node*q;
    int i=0;
    while(i!=idx&&p!=NULL)
    {
        p=p->next;
        i++;
    }
    if(p==NULL)
    {
        return 0;
    }
    q=(node*)malloc(sizeof(node));
    q->val=val;
    if(p->next==NULL)
    {
        p->next=q;
        q->next=NULL;
    }
    else
    {
        q->next=p->next;
        p->next=q;
    }
    return 0;
}
int editNode(idx,val)
{
    node* p=head;
    int i=0;
    while(i!=idx&&p!=NULL)
    {
        p=p->next;
        i++;
    }
    if(p==NULL)
    {
        return 0;
    }
    p->val=val;
    return 0;
}
int delNode(idx)
{
    node* p=head;
    node*q;
    int i=0;
    while(i!=idx&&p!=NULL)
    {
        q=p;
        p=p->next;
        i++;
    }
    if(p==NULL)
    {
        return 0;
    }
    q->next=p->next;
    free(p);
    return 0;
}
int appearNode(int idx)
{
    node* p=head;
    int i=0;
    while(i!=idx&&p!=NULL)
    {
        p=p->next;
        i++;
    }
    if(p==NULL)
    {
        return 0;
    }
    printf("%d\n",p->val);
    return 0;
}
//int debug()
//{
//    node* p=head;
//    while(p!=NULL){
//        printf("%d->",p->val);p=p->next;
//    }printf("\n");
//    return 0;
//}
int main()
{
    int op,idx,val;
    head=(node*)malloc(sizeof(node));
    head->next=NULL;
    head->val=111;
    while(scanf("%d%d%d",&op,&idx,&val)==3)
    {
        if(op!=1&&op!=2&&op!=3&&op!=4)
        {
            continue;
        }
        else if(op==1)
        {
            addNode(idx,val);
            //debug();
        }
        else if(op==2)
        {
            editNode(idx,val);
            //debug();
        }
        else if(op==3)
        {
            delNode(idx);
            //debug();
        }
        else
        {
            appearNode(idx);
        }
    }
    return 0;
}

```

### 1069浮点精确数

```c
#include<stdio.h>
#include<math.h>
int main()
{
    int p;
    double a,b,delta;
    while(scanf("%d%lf%lf",&p,&a,&b)==3)
    {
        delta=1.0;
        while(p-->0){delta/=10;}
        if(fabs(a-b)<delta){printf("0\n");}
        else if(a-b<0){printf("-1\n");}
        else{printf("1\n");}
    }
    return 0;
}

```

### 1070三角形归类

```c
#include<stdio.h>
#include<math.h>
void my_sort(int *a,int *b,int *c)
{
  int temp;
  if(*a>*b){temp=*a;*a=*b;*b=temp;}
    if(*a>*c){temp=*a;*a=*c;*c=temp;}
      if(*b>*c){temp=*b;*b=*c;*c=temp;}
}
int is_triangle(int a,int b,int c)
{
    if(a+b>c){return 1;}
    else{
        printf("not a triangle");return 0;
    }
}
void choose_angle(int a,int b,int c)
{
    if(c*c-a*a-b*b>0){printf("obtuse ");}
    else if(c*c-a*a-b*b==0){printf("right ");}
    else{printf("acute ");}
}
void choose_edge(int a,int b,int c)
{
    if(a!=b&&b!=c){printf("scalene");return;}
    if(a==b&&b==c){printf("equilateral");return;}
    if(a==b||b==c){printf("isosceles");return;}
}
int main()
{
    int a,b,c;
    while(scanf("%d%d%d",&a,&b,&c)==3){
        my_sort(&a,&b,&c);//按非递减排序
        if(is_triangle(a,b,c)){//判断是否构成三角形
        choose_angle(a,b,c);//按最大角类型分类
        choose_edge(a,b,c);//按照边长类型分类
        }
    printf("\n");
    }
    return 0;
}

```

### 1071字符串串烧

```c
#include<stdio.h>
#define N 210
void getnchar(char *str, int n)
{
    int i;
    for(i=0; i<n-1;)
    {
        str[i]=getchar();
        if(str[i]=='\n')
        {
            break;
        }
        i++;
    }
    str[i]='\0';
}
int my_strlen(char *str)
{
    int len=0;
    while(str[len]!='\0')
    {
        len++;
    }
    return len;
}
int my_strncat(char *dest, char *src, int n)
{
    int i=my_strlen(dest),j=my_strlen(src),k;
    for(k=0; k<j&&k<n; k++)
    {
        dest[i+k]=src[k];
    }
    dest[i+k]='\0';
    return k;
}
int my_strspn(char *str, char *keys)
{
    int i=0,j;
    while(str[i]!='\0')
    {
        j=0;
        while(keys[j]!='\0')
        {
            if(keys[j]==str[i])
            {
                break;
            }
            j++;
        }
        if(keys[j]=='\0')
        {
            break;
        }
        i++;
    }
    return i;
}
int main()
{
    int nCase,x;
    char a[N],b[N],c[N];
    scanf("%d",&nCase);
    getchar();
    while(nCase--)
    {
        getnchar(a,N);
        getnchar(b,N);
        getnchar(c,N);
        scanf("%d",&x);
        getchar();
        printf("%d\n",my_strlen(a));
        printf("%d %s\n",my_strncat(a,b,x),a);
        printf("%d\n",my_strspn(b,c));
    }
    return 0;
}
```

### 1072石敢腐

```c
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#define N 110
#define D debug();
#define E debug1();
void get_space()//取走所有空白字符
{
    char temp;
    while(1)
    {
        temp=getchar();
        if(temp==' '||temp=='\t'||temp=='\n')
        {
            continue;
        }
        else
        {
            ungetc(temp,stdin);
            break;
        }
    }
}
void debug()
{
    printf("I am here\n");
}
void debug1()
{
    printf("#\n");
}
int shiganfu(const char *format, void *ptr)
{
    char *a,b;
    int temp,i,j,k;
    if(strcmp(format,"%d")==0)
    {
        get_space();
        b=getchar();
        if(b==EOF)
        {
            return EOF;
        }

        if(b<'0'||b>'9')
        {
            ungetc(b,stdin);
            return 0;
        }
        ungetc(b,stdin);
        i=temp=0;
        a=(char *)ptr;
        while(1)
        {
            a[i]=getchar();
            if(a[i]<'0'||a[i]>'9')
            {
                if(a[i]!=EOF)
                {
                    ungetc(a[i],stdin);
                }
                for(j=1,i--; i>-1; i--)
                {
                    temp=temp+j*(a[i]-'0');
                    j*=10;
                }
                *(int *)ptr=temp;
                return 1;
            }
            i++;
        }
    }
    else if(strcmp(format,"%c")==0)
    {
        getchar();
        b=getchar();
        if(b==EOF)
        {
            return EOF;
        }
        else
        {
            *(char*)ptr=b;
            return 1;
        }
    }
    else if(strcmp(format,"%s")==0)
    {
        get_space();
        b=getchar();
        if((b)==EOF)
        {
            return -1;
        }
        ungetc(b,stdin);


        a=(char *)ptr;
        i=0;
        while(1)
        {
            a[i]=getchar();
            if(a[i]==' '||a[i]=='\t'||a[i]=='\n')
            {
                ungetc(a[i],stdin);
                a[i]='\0';
                return 1;
            }
            if(a[i]==EOF)
            {
                a[i]='\0';
                return 1;
            }
            i++;
        }
    }
    else if(strcmp(format,"\\n")==0)
    {
        while(1)
        {
            b=getchar();
            if(b==' '||b=='\t'||b=='\n')
            {
                continue;
            }
            else  if(b==EOF)
            {
                return 0;
            }
            else
            {
                ungetc(b,stdin);
                return 0;
            }
        }
    }
    else
    {
        return -3;
    }
}
int main()
{
//    char s,t,r;while(1){
//    s=getchar();printf("%c**HAHA!1\n",s);
//    t=getchar();printf("%c**HAHA!2\n",t);
//    r=getchar();printf("%d**HAHA!3\n",r);
//    if(s==EOF){printf("%d**HAHA!4\n",s);}
//               getchar(); printf("HAHA5!\n");}
//
////测试ctrl+z的问题

    void *ptr=malloc(sizeof(char)*N);
    char format[10];
    int i,ret;
    while(1)
    {
        get_space();

//        i=0;
//        while(1)
//        {
//            format[i]=getchar();
//            if(format[i]==' '||i==2)
//            {
//                format[i]='\0';
//                break;
//            }
//            else
//            {
//                i++;
//            }
//        }
        // //puts(format);
        format[0]=getchar();
        if(format[0]==EOF)
        {
            break;
        }
        else
        {
            format[1]=getchar();
            format[2]='\0';
            ret=-10;
            ret=shiganfu(format,ptr);

            printf("%d",ret);
            if(ret==1)
            {
                if(strcmp(format,"%s")==0)
                {
                    printf(" %s",(char*)ptr);
                }
                else if(strcmp(format,"%d")==0)
                {
                    printf(" %d",*(int*)ptr);
                }
                else if(strcmp(format,"%c")==0)
                {
                    printf(" %c",*(char*)ptr);
                }
                else ;
            }
            printf("\n");

        }
    }
    free(ptr);
    return 0;
}

```

### 1073合并有序数组

```c
#include<stdio.h>
#define N 1000000
int main()
{
    int n;
    long long s,t,i,j;
    int a[N];
    int b[N];
    for(i=0;i<N;i++){a[i]=b[i]=0;}
    scanf("%d",&n);
    while(n-->0){
        scanf("%lld",&s);
        for(i=0;i<s&&i<N;i++){scanf("%d",&a[i]);
        //printf("s=%lld\ti=%lld\ta[%lld]=%d\n",s,i,i,a[i]);
        }
        scanf("%lld",&t);
        for(i=0;i<t&&i<N;i++){scanf("%d",&b[i]);
        //printf("t=%lld\ti=%lld\tb[%lld]=%d\n",t,i,i,b[i]);
        }
        for(i=0,j=0;i<s&&j<t;){
            if(a[i]<b[j]||a[i]==b[j]){
                printf("%d ",a[i]);
                if(a[i]==b[j]){j++;}
                i++;
            }
            else{
                while(a[i]>b[j]&&j<t&&i<s){
                    printf("%d ",b[j]);
                    j++;
                }
            }
        }
        if(i>s-1){
            while(j<t){printf("%d ",b[j]);j++;}
        }
        if(j>t-1){
            while(i<s){printf("%d ",a[i]);i++;}
        }
        if(i>s-1&&j>t-1){printf("\n");}
    }
    return 0;
}

```

### 完美字符串

```c
#include<stdio.h>
int main(){
    char s[10001];
    int times[26]={0};
    int timesTemp;
    long ans=0;
    int count=0,count1;
    gets(s);
    while(s[count]!='\0'){
        times[(s[count]-'A')%32]++;
        count ++;
    }
    for(count=0;count<26;count++){
        for(count1=count+1;count1<26;count1++){
            if(times[count]<times[count1]){
                timesTemp=times[count];times[count]=times[count1];times[count1]=timesTemp;
            }
        }
    }
    timesTemp=26;
    for(count=0;count<26;count++){
        ans=ans+timesTemp*times[count];
         timesTemp--;
    }
    printf("%ld",ans);
}

```