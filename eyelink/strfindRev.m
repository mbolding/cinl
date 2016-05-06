function s = strfindRev( s1,s2,sp )
% Search string s1 backward from starting point sp until finding a string s2.
% Returns the string that contains s2 and sp.
% Usage: s = findStrRev( s1,s2,st )
% s1: source string
% s2: target string
% sp: starting point
ss=s1(sp);
i=1;
while 1
    ss=[s1(sp-i) ss];
    if strfind(ss,s2)
        s=ss;
        break;
    end
        i=i+1;
end



