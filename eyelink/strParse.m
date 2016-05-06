function c=strParse(s1,s2,s3)
c=struct('token',{});
line=s1;
tcount=1;
while 1
    [t remain] = strtok(line, [s2 s3]);
    c(tcount).token=strtrim(t);
    tcount=tcount+1;
    if length(remain)>1
        line=remain;
    else
        break;
    end
end