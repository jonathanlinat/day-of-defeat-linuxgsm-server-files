/* 
* Version 2.30b AMXX
* (c) Copyright 2002-2003, Deagles 
* (c) Copyright for original Mapchooser by OLO 
* This file is provided as is, with absolutely no warranty. 
* You may not edit this file for re-publishing without explicet permission 
* from Deagles or OLO 
* Covered by GPL Licences according to amxmodx.org/forums Rules.
* This is the final "official" version of this plugin to be released 

2.30b: Moved ALL config files to configs/_deagles_map_manage/, if the directory exists otherwise configs/

2.30: Fix so-called "hardcoded paths" and moved config files to configs folder.

2.27d : Fix generation of allmaps.txt (removed.)

New in 2.27c

  Fixed dmap_maxcustom <N> to allow 0 (no custom maps) in the vote.  I'm not sure
   why this was limited to being greater or equal to 1 in the first place (call it an oversight).

New in 2.27

  Added randomization of "nextmap" when the current map being played does not exist in the server mapcycle.txt
  Fixed dmap_maxcustom <N> to strictly control the maximum # of custom maps that appear in the vote 
    (voted or filled), so that the function does not just control the maximum number of maps that can be nominated.
  Config files remain in /amxmodx/ directory
New in 2.20 (AMXX)

  Release #3 of 2.10j, fixed bugs with strtonum() and warning messages about # arguments.
  Config files need to be placed in your <mod>/amxmodx/ Folder!! (not the config folder or anywhere else)

  ***Added automatic generation of <mod>/amxmodx/allmaps.txt file***
	-It will generate this list based on maps in your /MAPS folder, the first time you run this plugin.
	Cached maps such as default maps will need to be added *manually* to this file in notepad and to the 
	standardmaps.ini, if the mod differs from CS 1.6.

  Fixed "extra long" waits for map to change in mods other than CS.
  Fixed flooding of vote menu in NS, due to the chat messages being displayed at vote time.
  Fixed color hudmessage that "map will change in N seconds" when Round Mode is being used.
  Changes from AMX version: NO more strtonum() or numtostr() integrated, had to make these 2 functions.
  cstrike_running becomes function not variable.
*/ 
#include <amxmodx> 
#include <amxmisc> 
#define MAX_MAPS_AMOUNT 128 
new maps_to_select, isbuytime=0, isbetween=0 
new ban_last_maps=0, quiet=0 //quiet=0 (words and sounds) quiet=1 (words only, no sound) quiet=2 (no sound, no words) 
new Float:rtvpercent,Float:thespeed,Float:oldtimelimit 
new minimum=1,minimumwait=10, enabled=1,cycle=0,dofreeze=1, maxnom=3, maxcustnom=5,  frequency=3,oldwinlimit=0, addthiswait=0
new mapsurl[64] ,amt_custom=0
new isend=0, isspeedset=0, istimeset=0,iswinlimitset=0,istimeset2=0,mapssave=0,atstart 
new usestandard=1, currentplayers=0,activeplayers=0, counttovote=0, countnum=0 
new inprogress=0, rocks=0, rocked[32], hasbeenrocked=0, waited=0 
new pathtomaps[64] 
new custompath[50]
new nmaps[MAX_MAPS_AMOUNT][32] 
new listofmaps[MAX_MAPS_AMOUNT][32] 
new totalbanned=0 
new banthesemaps[MAX_MAPS_AMOUNT][32] 
new totalmaps=0 
new lastmaps[100+1][32] 
new bannedsofar=0 
new standard[50][32] 
new standardtotal=0 
new nmaps_num=0//this is number of nominated maps 
new nbeforefill 
new nmapsfill[MAX_MAPS_AMOUNT][32] 
new num_nmapsfill//this is number of maps in users admin.cfg file that are valid 
new bool:is_cstrike
new nnextmaps[10], nvotes[12], nmapstoch, before_num_nmapsfill=0, bool:mselected = false 
new logfilename[256] 
new teamscore[2], last_map[32] 
new Nominated[MAX_MAPS_AMOUNT]//? 
new whonmaps_num[MAX_MAPS_AMOUNT] 
forward public hudtext16(textblock[],colr,colg,colb,posx,posy,screen,time,id) ;
forward bool:isbanned(map[]); 
forward bool:iscustommap(map[]); 
forward bool:islastmaps(map[]); 
forward bool:isnominated(map[]); 
forward public handle_nominate(id,map[]); 
forward available_maps(); 
forward public getready(); 
forward public timetovote(); 
forward public messagefifteen(); 
forward public messagenominated(); 
forward public messagemaps(); 
forward public stopperson() 
forward public countdown(); 
forward public rock_it_now(); 
forward public timedisplay(); 
forward public messagethree(); 
public client_connect(id){ 
   if (!is_user_bot(id)) 
      currentplayers++ 
} 
public numtostr(tempNum,temp[]){
  //console_print(0,"1) numtostr: called with num=%d",tempNum)
  format(temp,31,"%d",tempNum)
  //console_print(0,"2) numtostr: returning string= %s",temp)
  return
}
public strtonum(str[])
{
	//console_print(0,"strtonum called with str[]= %s",str)
	new sum=0,k=strlen(str)-1,num,factor=1
	//console_print(0,"strtonum called with str[]= %s will traverse from [%d] to [0]",str,k)

	while(k>=0){
		num=str[k]
		num-=48
		if(num<0 || num>9)
			break
		sum+=num*factor
		//console_print(0,"num=%d new sum=%d, current factor=%d",num,sum,factor)
		factor*=10
		k--
	}
	//new strthis[30],thisnum=1412
	//numtostr(thisnum,strthis)
	//console_print(0,"3) num to str: produces:%s",strthis)
	//console_print(0,"returning sum: %d",sum)
	return sum
	/*
	These errors in first release of 2.10j (1) is now fixed
	strtonum called with str[]= 60
	returning sum: 588
	strtonum called with str[]= 49
	returning sum: 577
	strtonum called with str[]= 5
	returning sum: 53
	strtonum called with str[]= 3
	returning sum: 51
	strtonum called with str[]= 5
	returning sum: 53
	strtonum called with str[]= 1
	returning sum: 49
	strtonum called with str[]= 10
	returning sum: 538
	strtonum called with str[]=  3
	*/
}

public loopmessages() 
{ 
   if(quiet==2)//quiet=0 (words and sounds) quiet=1 (words only, no sound) quiet=2 (no sound, no words) 
      return PLUGIN_HANDLED 
   new timeleft = get_timeleft() 
   new partialtime=timeleft%370       
   new maintime=timeleft%600 
   if((maintime>122&&maintime<128)&&timeleft>114) 
      set_task(1.0,"timedisplay",454510,"",0,"a",5)       

   if((partialtime>320&&partialtime<326)&&!cycle) 
   { 

      set_task(3.0,"messagethree",987300)//,"",0,"a",4) 
      return PLUGIN_HANDLED 
   } 
   return PLUGIN_HANDLED 
} 
public timedisplay() 
{ 
   new timeleft=get_timeleft() 
   new seconds=timeleft%60 
   new minutes=floatround((timeleft-seconds)/60.0) 
   if(timeleft<1) 
   { 
      remove_task(454510) 
      remove_task(454500) 
      remove_task(123452) 
      remove_task(123499) 
      return PLUGIN_HANDLED 
   } 
   if(timeleft>140) 
      remove_task(454500) 
   if(timeleft>30) 
      set_hudmessage(255,255,220, 0.02, 0.2, 0, 1.0, 1.04, 0.0, 0.05, 3) 
   else 
      set_hudmessage(210,0 ,0, 0.02, 0.15, 0, 1.0, 1.04, 0.0, 0.05, 3) 
      //Flashing red:set_hudmessage(210,0 ,0, 0.02, 0.2, 1, 1.0, 1.04, 0.0, 0.05, 3)       
   show_hudmessage(0,"Time Left^n%d:%02d", minutes,seconds) 
   if(timeleft<70 && (timeleft%5)==1 ) 
   { 
      new smap[32] 
      get_cvar_string("amx_nextmap",smap,31) 
      set_hudmessage(0,132,255, 0.02, 0.27, 0, 5.0, 5.04, 0.0, 0.5, 8) 
      show_hudmessage(0,"Nextmap: %s",smap) 
   } 
   return PLUGIN_HANDLED 
       
} 
public messagethree() 
{ 
   new timeleft = get_timeleft() 
   new time2=timeleft-timeleft%60 
   new minutesleft=floatround(float(time2)/60.0) 
   new mapname[32] 
   get_mapname(mapname,31) 
   new smap[32] 
   get_cvar_string("amx_nextmap",smap,31) 
   if(minutesleft>=2&&!mselected) 
      client_print(0,print_chat,"A Vote will occur to choose the next map in %d %s",(minutesleft==3||minutesleft==2)?timeleft-100:minutesleft-2,(minutesleft==3||minutesleft==2)?"seconds":"minutes") 
   else 
   if(mselected) 
      client_print(0,print_chat,"Players have voted for %s...Map change is in %d seconds",smap,timeleft) 
   else 
   if(minutesleft<=2&&timeleft) 
   	client_print(0,print_chat,"Current map is %s.  Voting is in progress for nextmap...",mapname) 

       
} 
public client_putinserver(id){ 
   if(!is_user_bot(id)) 
      activeplayers++ 

} 
public client_disconnect(id){ 
   remove_task(987600+id) 
   remove_task(127600+id) 
   if(is_user_bot(id)) 
      return PLUGIN_HANDLED 

   currentplayers-- 
   activeplayers-- 
   if(rocked[id]) 
   { 
      rocked[id]=0 
      rocks-- 
   } 
   if(get_timeleft()>160) 
      if(!mselected&&!hasbeenrocked&&!inprogress) 
         check_if_need() 
   new kName[32] 
   get_user_name(id,kName,31) 
   new n=0 
   while(Nominated[id]>0&&n<nmaps_num) 
      if(whonmaps_num[n]==id){ 
         if(get_timeleft()>50&&quiet!=2)//quiet=0 (words and sounds) quiet=1 (words only, no sound) quiet=2 (no sound, no words) 
         { 
            client_print(0,print_chat,"%s has left; %s is no longer nominated",kName,nmaps[n]) 
            log_to_file(logfilename,"%s has left; %s is no longer nominated",kName,nmaps[n]) 
         } 
         new j=n 
         while(j<nmaps_num-1) 
         { 
            whonmaps_num[j]=whonmaps_num[j+1] 
            nmaps[j]=nmaps[j+1] 
            j++ 
         } 
         nmaps_num-- 
         Nominated[id]=Nominated[id]-1 
      } 
      else 
         n++ 
   return PLUGIN_HANDLED 
} 
public list_maps(id){ 
   new m,idreal=id,iteration=0 
   client_print(id,print_chat, "A Complete Map List of %d maps is being displayed in your console",totalmaps) 
   if(totalmaps-(50*iteration)>=50) 
      console_print(idreal, "************ Maps %d - %d :***********",iteration*50+1,iteration*50 + (50)) 
   else 
      console_print(idreal, "************ Maps %d - %d :***********",iteration*50+1,iteration*50 + (totalmaps-iteration*50) ) 

   for(m=50*iteration;(m<totalmaps&&m<50*(iteration+1));m+=3) 
      if(m+1<totalmaps) 
         if(m+2<totalmaps) 
            console_print(id,"   %s   %s   %s",listofmaps[m],listofmaps[m+1],listofmaps[m+2]) 
         else 
            console_print(id,"   %s   %s",listofmaps[m],listofmaps[m+1]) 
      else 
         console_print(id,"   %s",listofmaps[m]) 
   if(50*(iteration+1)<totalmaps) 
   { 
      new kIdfake[32] 
      numtostr((id+50*(iteration+1)),kIdfake) 
      client_print(idreal, print_console,"Please wait; loading more maps from this server to display in your console...") 
      set_task(4.0,"more_list_maps",127600+id,kIdfake,6) 
   } 
   return PLUGIN_CONTINUE 
} 
public more_list_maps(idfakestr[]) 
{ 
   new idfake=strtonum(idfakestr) 
   new m,idreal=idfake,iteration=0 
   while(idreal>=50){ 
      idreal-=50 
      iteration++ 
   }//Now idreal is the real id of client 
    
   if(totalmaps-(50*iteration)>=50) 
      console_print(idreal,"************ Maps %d - %d :***********",iteration*50+1,iteration*50 + (50)) 
   else 
      console_print(idreal, "************ Maps %d - %d :***********",iteration*50+1,iteration*50 + (totalmaps-iteration*50) ) 
   for(m=50*iteration;(m<totalmaps&&m<50*(iteration+1));m+=3) 
      if(m+1<totalmaps) 
         if(m+2<totalmaps) 
            console_print(idreal,"   %s   %s   %s",listofmaps[m],listofmaps[m+1],listofmaps[m+2]) 
         else 
            console_print(idreal,"   %s   %s",listofmaps[m],listofmaps[m+1]) 
      else 
         console_print(idreal,"   %s",listofmaps[m]) 

   if(50*(iteration+1)<totalmaps) 
   { 
      new kIdfake[32] 
      numtostr((idreal+50*(iteration+1)),kIdfake) 
      client_print(idreal, print_console,"Please wait; loading more maps from this server to display in your console...") 
      set_task(2.0,"more_list_maps",127600+idreal,kIdfake,6) 
   } 
   else  //Base case has been reached 
      client_print(idreal, print_console,"Finished displaying %d maps in your console.",totalmaps) 

} 
public say_nextmap(id){ 
   new timeleft = get_timeleft() 
   new time2=timeleft-timeleft%60 
   new minutesleft=floatround(float(time2)/60.0) 
   new mapname[32] 
   get_mapname(mapname,31) 
   new smap[32] 
   get_cvar_string("amx_nextmap",smap,31) 
   if(minutesleft>=2&&!mselected) 
      client_print(0,print_chat,"A Vote will occur in %d %s Say ^"nominations^" for a list of nominations.",(minutesleft==3||minutesleft==2)?timeleft-100:minutesleft-2,(minutesleft==3||minutesleft==2)?"sec.":"min.") 
   else 
   if(mselected) 
      client_print(0,print_chat,"Players have voted for %s...Map change is in %d seconds",smap,timeleft) 
   else 
      if(inprogress) 
         client_print(0,print_chat,"Current map is %s.  Voting is in progress for nextmap...",mapname) 
   return PLUGIN_HANDLED 
} 
public check_if_need(){ 
   new Float:ratio=rtvpercent 
   new needed=floatround(float(activeplayers)*ratio+0.49) 
   new timeleft = get_timeleft() 
   new Float:minutesleft=float(timeleft)/60.0 
   new Float:currentlimit=get_cvar_float("mp_timelimit") 
   new Float:minutesplayed=currentlimit-minutesleft 
   new wait 
   wait=minimumwait 
   if((minutesplayed+0.5)>=(float(wait))) 
   { 
      if(rocks>=needed&&rocks>=minimum) 
      { 
         client_print(0,print_chat,"Enough people (%d) now have said ^"rockthevote^", so a vote will begin shortly",rocks) 
         set_hudmessage(222, 70,0, -1.0, 0.3, 1, 10.0, 10.0, 2.0, 4.0, 8)    
         show_hudmessage(0,"Due to %d players Rocking the vote,^n Vote is now rocked^nVoting Will begin shortly",rocks ) 
         hasbeenrocked=1    
         inprogress=1 
         mselected=false 
         set_task(15.0, "rock_it_now",765100)       
      } 
   } 
} 
public rock_the_vote(id){ 
   new Float:ratio=rtvpercent 
   new needed=floatround(float(activeplayers)*ratio+0.49) 
   new kName[32] 
   get_user_name(id,kName,31) 
   new timeleft = get_timeleft() 
   new Float:minutesleft=float(timeleft)/60.0 
   new Float:currentlimit=get_cvar_float("mp_timelimit") 
   new Float:minutesplayed=currentlimit-minutesleft 
   new wait 
   wait=minimumwait 
   if(cycle) 
   { 
      client_print(id,print_chat,"Voting has been disabled on this server") 
      return PLUGIN_CONTINUE 
   } 
   if(!enabled) 
   { 
      client_print(id,print_chat,"Rockthevote has been disabled on this server") 
      return PLUGIN_CONTINUE 
   } 
   if(inprogress) 
   { 
      client_print(id,print_chat,"Voting is in progress or is about to begin") 
      return PLUGIN_CONTINUE 
   } 
   if(mselected) 
   { 
      new smap[32] 
      get_cvar_string("amx_nextmap",smap,31) 
      client_print(id,print_chat,"Voting is complete and players have voted for %s, map will change in %d sec.",smap,get_timeleft()) 
      return PLUGIN_CONTINUE    
   } 
   if(hasbeenrocked) 
   {       
      client_print(id,print_chat,"%s, Voting has been rocked on this map already, it cannot be rocked twice on the same map",kName) 
      return PLUGIN_CONTINUE       
   } 
   if(timeleft<120) 
   { 
      if(timeleft>1)    
         client_print(id,print_chat,"There is not enough time remaining on the map to rockthevote") 
      else 
         client_print(id,print_chat,"You cannot rockthevote, there is no timelimit")    
      return PLUGIN_CONTINUE 
   } 
   if((minutesplayed+0.5)<(float(wait))) 
   { 
      if(float(wait)-0.5-minutesplayed>0.0) 
         client_print(id,print_chat,"%s, you must wait another %d minutes until you can say ^"rockthevote^"", 
            kName,(floatround(float(wait)+0.5-minutesplayed)>0)?(floatround(float(wait)+0.5-minutesplayed)):(1)) 
      else 
         client_print(id,print_chat,"Under 1 minute until you may rockthevote") 
      if ((get_user_flags(id)&ADMIN_MAP)) 
         console_print(id,"%s, You have admin privilidges, you may try to use the command dmap_rockthevote, to Force a vote",kName) 
      return PLUGIN_CONTINUE 
   } 
   if(!rocked[id]) 
   { 
      rocked[id]=1 
      rocks++ 
   } 
   else 
   { 
      client_print(id,print_chat,"%s, you already have rocked the vote, you cannot rockit twice!",kName) 
      return PLUGIN_CONTINUE 
   } 
   if(rocks>=needed&&rocks>=minimum) 
   { 
      client_print(0,print_chat,"Enough people (%d) now have said ^"rockthevote^", so a vote will begin shortly",rocks) 
      set_hudmessage(222, 70,0, -1.0, 0.3, 1, 10.0, 10.0, 2.0, 4.0, 8)    
      show_hudmessage(0,"Due to %d players Rocking the vote,^n Vote is now rocked^nVoting Will begin shortly",rocks ) 
      hasbeenrocked=1    
      inprogress=1 
      mselected=false 
      set_task(15.0, "rock_it_now",765100)       
   } 
   else 
      client_print(0,print_chat,"%d more players must ^"rockthevote^" to start a vote",((needed-rocks)>(minimum-needed))?(needed-rocks):(minimum-rocks)) 
   return PLUGIN_CONTINUE 
} 
public rock_it_now(){ 
   new temprocked=hasbeenrocked 
   hasbeenrocked=1 
   new timeleft = get_timeleft() 
   new Float:minutesleft=float(timeleft)/60.0 
   new Float:currentlimit=get_cvar_float("mp_timelimit") 
   new Float:minutesplayed=currentlimit-minutesleft 
   new Float:timelimit 
   counttovote=0 
   remove_task(459200) 
   remove_task(459100) 
   timelimit=float(floatround(minutesplayed+1.5))       
   if(timelimit>0.4) 
   {    
      oldtimelimit=get_cvar_float("mp_timelimit") 
      istimeset=1 
      set_cvar_float("mp_timelimit", timelimit) 
      if(quiet!=2) 
         console_print(0,"Time limit changed to %d To enable vote to occur now", 
                     floatround(get_cvar_float("mp_timelimit"))) 
      log_to_file(logfilename,"Time limit changed to %d To enable vote to occur now", 
                     floatround(get_cvar_float("mp_timelimit")))    
   } 
   else 
   { 
      console_print(0,"Unable to change time limit, vote is not rocked") 
      log_to_file(logfilename,"Will not set a timelimit of %d, vote is not rocked, seconds left on map:%d",floatround(timelimit),timeleft) 
      new inum,players[32],i 
      get_players(players,inum,"c") 
      for(i = 0 ;i < inum; ++i) 
         rocked[i]=0 
      rocks=0 
      hasbeenrocked=temprocked 
      return PLUGIN_HANDLED 
   } 
   timeleft=get_timeleft() 
   inprogress=1 
   mselected=false 
   if(quiet!=2){ 
      set_hudmessage(0, 222,50, -1.0, 0.23, 1, 6.0, 6.0, 1.0, 1.0, 8)    
      show_hudmessage(0,"Attention: Map Voting will begin in 10 seconds") 
   } 
   else 
      client_print(0,print_chat,"Map voting will begin in 10 seconds") 
   if(quiet==0) 
      client_cmd(0,"spk ^"get red(e80) ninety(s45) to check(e20) use _comma(e10) bay(s18) mass(e42) cap(s50)^"")    
   set_task(3.5,"getready",459100) 
   set_task(10.0,"startthevote") 
   remove_task(454500) 
   remove_task(123452) 
   rocks=0 
   new inum,players[32],i 
   get_players(players,inum,"c") 
   for(i = 0 ;i < inum; ++i) 
   { 
      rocked[i]=0 
   } 
   set_task(2.18,"calculate_custom")    
   return PLUGIN_HANDLED 
} 

public admin_rockit(id){ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   new arg[32] 
   read_argv(1,arg,31) 
   new kName[32], timeleft=get_timeleft() 
   get_user_name(id,kName,31) 

   if(timeleft<180.0) 
   { 
      console_print(id,"Not enough time remaining to rockthevote") 
      return PLUGIN_HANDLED 
   } 
   if(inprogress||hasbeenrocked||isend) 
   { 
      console_print(id,"Voting is in progress or is about to begin or over or vote has been rocked already.") 
      return PLUGIN_HANDLED 
   } 
   if(cycle) 
   { 
      console_print(id,"Cycle Mode is on.  To enable Voting Mode, use command dmap_votemode") 
      return PLUGIN_HANDLED 
   } 
   if(!mselected) 
      switch(get_cvar_num("amx_show_activity")){ 
         case 2:   client_print(0,print_chat,"Vote has been rocked by admin %s",kName) 
         case 1:   client_print(0,print_chat,"ADMIN used command ^"amx_rockthevote^"") 
      }    
   else 
      switch(get_cvar_num("amx_show_activity")){ 
         case 2:   client_print(0,print_chat,"ADMIN <%s> is requesting a revote, voting will reoccur shortly",kName) 
         case 1:   client_print(0,print_chat,"ADMIN is requesting a revote, voting will reoccur shortly") 
      } 
   remove_task(123450) 
   remove_task(123400) 
   remove_task(123452) 
   remove_task(123499) 
   counttovote=0 
   remove_task(459200) 
   remove_task(459100) 
   log_to_file(logfilename,"Admin: <%s> calls rockthevote with %d seconds left on map",kName,timeleft) 
   inprogress=1 
   mselected=false 
   set_task(15.0, "rock_it_now",765100)
   set_task(0.18,"calculate_custom")    
   return PLUGIN_HANDLED 
} 

public check_votes(){ 
   new timeleft=get_timeleft() 
   new b = 0 ,a  
   for(a= 0; a < nmapstoch; ++a) 
      if (nvotes[b] < nvotes[a])  
         b = a 
   if ( nvotes[maps_to_select] > nvotes[b] ) { 
      new mapname[32] 
      get_mapname(mapname,31) 
      new Float:steptime = get_cvar_float("amx_extendmap_step") 
      set_cvar_float("mp_timelimit", get_cvar_float("mp_timelimit") + steptime ) 
      //oldtimelimit=get_cvar_float("mp_timelimit") 
      istimeset=1 

      if(quiet!=2){      
         set_hudmessage(222, 70,0, -1.0, 0.4, 0, 4.0, 10.0, 2.0, 2.0, 8)    
         show_hudmessage(0,"Due to the vote, Current map will ^nbe extended for the next %.0f minutes", steptime ) 
         if(quiet!=1)  client_cmd(0,"speak ^"barney/waitin^"") 
      } 
      client_print(0,print_chat,"Current map will be extended to next %.0f minutes", steptime ) 
      log_to_file(logfilename,"Vote: Voting for the nextmap finished. Map %s will be extended to next %.0f minutes",  
      mapname , steptime ) 
      inprogress=isend=0 
      nmaps_num=nbeforefill 
      num_nmapsfill=before_num_nmapsfill 
      return PLUGIN_HANDLED 
   } 
   if ( nvotes[b] && nvotes[maps_to_select+1] <= nvotes[b] ) 
   { 
   set_cvar_string("amx_nextmap", nmaps[nnextmaps[b]] ) 
   new smap[32] 
   get_cvar_string("amx_nextmap",smap,31) 
   new players[32], inum 
   get_players(players,inum,"c") 
   if(quiet!=2){ 
      new whenChange[40]
      if(get_cvar_float("enforce_timelimit")==1.0 && is_cstrike)
		format(whenChange,39,"in %d seconds",timeleft)
      else
		format(whenChange,39,"shortly")		
      set_hudmessage(222, 70,0, -1.0, 0.36, 0, 4.0, 10.0, 2.0, 2.0, 8) 
      if(timeleft<=0||timeleft>300) 
         show_hudmessage(0,"Attention: Map %s wins with %d Votes.^nMap will change at end of this round",nmaps[nnextmaps[b]],nvotes[b],timeleft)    
      else 
         if(iscustommap(nmaps[nnextmaps[b]])&&usestandard) 
         { 
            set_hudmessage(0,152,255, -1.0, 0.22, 0, 4.0, 7.0, 2.1, 1.5, 8)       
            show_hudmessage(0,"Map %s wins with %d Votes.^nMap will change %s",nmaps[nnextmaps[b]],nvotes[b],whenChange)    
            //set_hudmessage(0,152,255, -1.0, 0.38, 0, 4.0, 7.0, 2.1, 1.5, 7) 
            client_print(0,print_notify,"This is a custom map, you may need to download it!") 
         } 
         else{ 
            set_hudmessage(0,152,255, -1.0, 0.22, 0, 4.0, 7.0, 2.1, 1.5, 8) 
            show_hudmessage(0,"Attention: Map %s wins with %d Votes.^nMap will change %s",nmaps[nnextmaps[b]],nvotes[b],whenChange) 
         } 
      if( (containi(mapsurl,"www")!=-1||containi(mapsurl,"http")!=-1) &&iscustommap(nmaps[nnextmaps[b]])) 
      { 
         //set_hudmessage(0,152,255, -1.0, 0.70, 1, 4.0, 12.0, 2.1, 1.5, 7)             
         client_print(0,print_chat,"You can download Custom maps from %s",mapsurl) 
      } 
      if(quiet!=1)   client_cmd(0,"speak ^"barney/letsgo^"")//quiet=0 (words and sounds) quiet=1 (words only, no sound) quiet=2 (no sound, no words)  
   } 
   } 
   new smap[32] 
   get_cvar_string("amx_nextmap",smap,31) 
   client_print(0,print_chat,"* Choosing finished. The nextmap will be %s", smap ) 
   log_to_file(logfilename,"Vote: Voting for the nextmap finished. The nextmap will be %s", smap) 
   inprogress=waited=0 
   isend=1 
   //WE ARE near END OF MAP; time to invoke Round mode ALgorithm 
   //set_task(2.0,"endofround",123452,"",0,"b") 
   new waituntilready=timeleft-60 
   if(waituntilready>30) 
   	waituntilready=30 
   if(waituntilready<=0||get_cvar_num("mp_winlimit")){
	addthiswait=4 
   	set_task(4.0,"RoundMode",333333) 
   }
   else{ 
      set_task(float(waituntilready),"RoundMode",333333) 
      addthiswait=waituntilready
   }
   nmaps_num=nbeforefill 
   num_nmapsfill=before_num_nmapsfill 
   set_task(2.18,"calculate_custom")
   return PLUGIN_HANDLED  
} 
public show_timer() 
   set_task(1.0,"timedis2",454500,"",0,"b") 
public timedis2() 
{  
   new timeleft=get_timeleft() 
   if((timeleft%5)==1 ) 
   { 
      new smap[32] 
      get_cvar_string("amx_nextmap",smap,31)
      set_hudmessage(0,132,255, 0.02, 0.27, 0, 5.0, 5.04, 0.0, 0.5, 8) 
      show_hudmessage(0,"Nextmap: %s",smap)
      if(waited<90)
        set_hudmessage(255,215,190, 0.02, 0.2, 0, 5.0, 5.04, 0.0, 0.5, 3)
      else
        set_hudmessage(210,0 ,0, 0.02, 0.15, 0, 5.0, 5.04, 0.0, 0.5, 3)
      //Flashing red:set_hudmessage(210,0 ,0, 0.02, 0.2, 1, 1.0, 1.04, 0.0, 0.05, 3)
      show_hudmessage(0,"Last Round")
   }
   return PLUGIN_HANDLED    
}
public timedis3() 
{ 
   new timeleft=get_timeleft() 
   if((timeleft%5)==1 ) 
   { 
      new smap[32] 
      get_cvar_string("amx_nextmap",smap,31) 
      set_hudmessage(0,132,255, 0.02, 0.27, 0, 5.0, 5.04, 0.0, 0.5, 8) 
      show_hudmessage(0,"Nextmap: %s",smap) 
      if(timeleft>30) 
      	set_hudmessage(255,215,190, 0.02, 0.2, 0, 5.0, 5.04, 0.0, 0.5, 3) 
      else 
      	set_hudmessage(210,0 ,0, 0.02, 0.15, 0, 5.0, 5.04, 0.0, 0.5, 3) 
      //Flashing red:set_hudmessage(210,0 ,0, 0.02, 0.2, 1, 5.0, 5.04, 0.0, 0.5, 3)       
      //countdown when "Enforcing timelimit"
      new seconds=timeleft%60 	
      new minutes=floatround((timeleft-seconds)/60.0)       
      show_hudmessage(0,"Time Left^n%d:%02d", minutes,seconds) 
   } 
   return PLUGIN_HANDLED    
} 
public RoundMode() 
{ 
   if(get_cvar_float("mp_timelimit")>0.1 && get_cvar_num("enforce_timelimit"))
   {
	remove_task(333333) 
	remove_task(454500)
	new timeleft=get_timeleft()
	if(timeleft<200){
		set_task(float(timeleft)-5.8,"endofround")
		set_task(1.0,"timedis3",454500,"",0,"b")
	}
	return PLUGIN_HANDLED
   }
   else{//bad indenting, but will not cause any problems ;)

	if(waited==0) 
		set_task(1.0,"show_timer") 
	if(isbetween || isbuytime || (waited + addthiswait) > 190 || (!is_cstrike&&(waited+addthiswait) >= 30)||activeplayers<2 )//Time to switch maps!!!!!!!! 
	{ 
	
		remove_task(333333) 
		remove_task(454500) 
		if(isbetween)
			set_task(3.9,"endofround")
		else
			endofround()
      	//switching very soon! 
   	} 
   	else 
   	{ 
      	waited+=5 
      	//if(waited>=15&&waited<=150&&get_timeleft()<7){ 
      	if((waited+addthiswait)<=190&&get_timeleft()>=0&&get_timeleft()<=15){ 
         		istimeset2=1 
         		set_cvar_float("mp_timelimit", get_cvar_float("mp_timelimit") + 2.0 )
			if(is_cstrike) 
         			client_print(0,print_chat,"** Extending time limit to allow players more time to finish the current round **") 
      	} 
      	set_task(5.0,"RoundMode",333333) 
   	} 
   }
   return PLUGIN_HANDLED
} 
public vote_count(id,key){ 
    
   if ( get_cvar_float("amx_vote_answers") ) { 
      new name[32] 
      get_user_name(id,name,31) 
      if ( key == maps_to_select ) 
         client_print(0,print_chat,"* %s chose map extending", name ) 
      else if ( key < maps_to_select ) 
         client_print(0,print_chat,"* %s chose %s", name, nmaps[nnextmaps[key]] ) 
   } 
   nvotes[key]=nvotes[key]+1    
   return PLUGIN_HANDLED 
} 
bool:isinmenu(id){ 
   new a 
   for(a=0; a<nmapstoch; ++a) 
      if (id==nnextmaps[a]) 
         return true 
   return false 
} 
public levelchange(){ 
   if(istimeset2==1)
   {  							 //Allow automatic map change to take place.
      set_cvar_float("mp_timelimit",get_cvar_float("mp_timelimit")-2.0)
      istimeset2=0
   }
   else{
	if(get_cvar_float("mp_timelimit")>=4.0){   //Allow automatic map change to take place.
		if(!istimeset)
		   oldtimelimit=get_cvar_float("mp_timelimit")
		set_cvar_float("mp_timelimit",get_cvar_float("mp_timelimit")-3)
		istimeset=1
	}else
		if(get_cvar_num("mp_winlimit"))      //Allow automatic map change based on teamscores
		{
			new largerscore
			largerscore=(teamscore[0]>teamscore[1])?teamscore[0]:teamscore[1]
			iswinlimitset=1
			oldwinlimit=get_cvar_num("mp_winlimit")
			set_cvar_num("mp_winlimit",largerscore)
		}
   }
   //If we are unable to achieve automatic level change, FORCE it.
   set_task(2.1,"DelayedChange",444444)
}
public changeMap(){ //Default event copied from nextmap.amx, and changed around.
  set_cvar_float( "mp_chattime" , 3.0 ) // make sure mp_chattime is long
  remove_task(444444)
  set_task( 1.85 , "DelayedChange")
}
public DelayedChange(){
   new smap[32] 
   get_cvar_string("amx_nextmap",smap,31) 
   server_cmd( "changelevel %s", smap ) 
} 
public endofround(){  //Call when ready to switch maps in (?) seconds 
   remove_task(123452) 
   remove_task(987111) 
   remove_task(333333) 
   remove_task(454510) 
   remove_task(454500) 
   remove_task(123499) 
   new smap[32] 
   get_cvar_string("amx_nextmap",smap,31) 
   set_task(6.0,"levelchange") //used to be 7.0
   if(quiet!=2){ 
      countnum=0 
      set_task(1.0,"countdown",123400,"",0,"a",6) 
      if(quiet!=1)   client_cmd(0,"speak ^"loading environment on to your computer^"") 
   } 
   else 
      client_print(0,print_chat,"Map is about to change") 
   /////////////////////////////////////////////// 
   client_print(0,print_chat,"The next map will be %s",smap) 
   if( (containi(mapsurl,"www")!=-1||containi(mapsurl,"http")!=-1) &&iscustommap(smap)) 
      client_print(0,print_chat,"**** You can download Custom maps like %s from %s ****",smap,mapsurl) 
   /////////////////////////////////////////////// 
   if(dofreeze){ 
      isspeedset=1    
      thespeed=get_cvar_float("sv_maxspeed") 
      set_cvar_float("sv_maxspeed", 0.0) 
      new players[32], inum, i 
      get_players(players,inum,"c") 
      for(i = 0 ;i < inum; ++i) 
      { 
         client_cmd(players[i],"drop") 
         client_cmd(players[i],"+showscores") 
      } 
   } 
   if(dofreeze) 
   	set_task(1.1,"stopperson",123450,"",0,"a",2) 
   return PLUGIN_HANDLED 
} 
public countdown() 
{ 
   new smap[32] 
   get_cvar_string("amx_nextmap",smap,31) 
   countnum++       
   set_hudmessage(150, 120,0, -1.0, 0.3, 0, 0.5, 1.1, 0.1, 0.1, 8)          
   show_hudmessage(0,"Map Changing to %s in %d seconds",smap,7-countnum) 
   return PLUGIN_HANDLED 
} 
public stopperson(){ 
   new players[32], inum, i 
   get_players(players,inum,"c") 
   if(isspeedset>=0&&isspeedset<2){   
      thespeed=get_cvar_float("sv_maxspeed") 
      isspeedset++
      set_cvar_float("sv_maxspeed", 0.0)
   }
   for(i = 0 ;i < inum; ++i) 
      client_cmd(players[i],"drop") 
   return PLUGIN_HANDLED 
} 

public display_message(){ 
   new timeleft = get_timeleft() 
   new parttime=timeleft%(frequency*60*2)  //460//period(minutes/cycle) * 60 seconds/minute = period in seconds 
   //if frequency=2 (every 2 minutes one message will appear) THIS FUNCTION COVERS 2 MESSAGES WHICH MAKES ONE CYCLE 
   //parttime=timeleft%240 
   new addition=frequency*60 
   if(mselected||inprogress||cycle) 
      return PLUGIN_CONTINUE 
   //if(parttime>310&&parttime<326&&timeleft>132) 
   if(parttime>(40+addition)&&parttime<(56+addition)&&timeleft>132) 
         set_task(3.0,"messagenominated",986100)   //,"",0,"a",4)    
   else 
      //if(parttime>155&&parttime<171&&timeleft>132)          
      if(parttime>30&&parttime<46&&timeleft>132) 
         set_task(10.0,"messagemaps",986200,"",0,"a",1)                   
      else if(timeleft>=117&&timeleft<132) 
         messagefifteen() 
   return PLUGIN_CONTINUE 
} 
// THIS IS UNTESTED, BUT SHOULD WORK 
/* 1.6 hudtext function 
Arguments: 
textblock: a string containing the text to print, not more than 512 chars (a small calc shows that the max number of letters to be displayed is around 270 btw) 
colr, colg, colb: color to print text in (RGB format) 
posx, posy: position on screen * 1000 (if you want text to be displayed centered, enter -1000 for both, text on top will be posx=-1000 & posy=20 
screen: the screen to write to, hl supports max 4 screens at a time, do not use screen+0 to screen+3 for other hudstrings while displaying this one 
time: how long the text shoud be displayed (in seconds) 
*/ 

public hudtext16(textblock[],colr,colg,colb,posx,posy,screen,time,id) { 
new y
if(contain(textblock,"^n") == -1) { // if there is no linebreak in the text, we can just show it as it is 
set_hudmessage(colr, colg, colb, float(posx)/1000.0, float(posy)/1000.0, 0, 6.0, float(time), 0.2, 0.2, screen) 
show_hudmessage(id,textblock) 
} 
else { // more than one line 
new out[128],rowcounter=0,tmp[512],textremain=true;y=screen 
new i = contain(textblock,"^n") 
copy(out,i,textblock) // we need to get the first line of text before the loop 
do { // this is the main print loop 
setc(tmp,511,0) // reset string 
copy(tmp,511,textblock[i+1]) // copy everything AFTER the first linebreak (hence the +1, we don't want the linebreak in our new string) 
setc(textblock,511,0) // reset string 
copy(textblock,511,tmp) // copy back remaining text 
i = contain(textblock,"^n") // get next linebreak position 
if((strlen(out)+i < 64) && (i != -1)) { // we can add more lines to the outstring if total letter count don't exceed 64 chars (decrease if you have a lot of short lines since the leading linbreaks for following lines also take up one char in the string) 
add(out,127,"^n") // add a linebreak before next row 
add(out,strlen(out)+i,textblock) 
rowcounter++ // we now have one more row in the outstring 
} 
else { // no more lines can be added 
set_hudmessage(colr, colg, colb, float(posx)/1000.0, float(posy)/1000.0, 0, 6.0, float(time), 0.2, 0.2, screen) // format our hudmsg 
if((i == -1) && (strlen(out)+strlen(textblock) < 64)) add(out,127,"^n") // if i == -1 we are on the last line, this line is executed if the last line can be added to the current string (total chars < 64) 
else { // not the last line or last line must have it's own screen 
if(screen-y < 4) show_hudmessage(id,out) // we will only print the hudstring if we are under the 4 screen limit 
screen++ // go to next screen after printing this one 
rowcounter++ // one more row 
setc(out,127,0) // reset string 
for(new j=0;j<rowcounter;j++) add(out,127,"^n") // add leading linebreaks equal to the number of rows we already printed 
if(i == -1) set_hudmessage(colr, colg, colb, float(posx)/1000.0, float(posy)/1000.0, 0, 6.0, float(time), 0.2, 0.2, screen) // format our hudmsg if we are on the last line 
else add(out,strlen(out)+i,textblock) // else add the next line to the outstring, before this, out is empty (or have some leading linebreaks) 
} 
if(i == -1) { // apparently we are on the last line here 
add(out,strlen(out)+strlen(textblock),textblock) // add the last line to out 
if(screen-y < 4) show_hudmessage(id,out) // we will only print the hudstring if we are under the 4 screen limit 
textremain = false // we have no more text to print 
} 
} 
} 
while(textremain) 
} 
return screen-y // we will return how many screens of text we printed 
} 
public messagenominated() 
{ 
   new string[256],string2[256],string3[512]
   if(quiet==2) 
      return PLUGIN_CONTINUE 
   if(nmaps_num<1) 
      format(string3,511,"No maps have been nominated, say ^"MAPNAME^" to nominate one") 
   else 
   { 
      new n=0,foundone=0 
      format(string,255,"Nominations so far for the next vote:^n") 
      while(n<3&&n<nmaps_num) 
         format(string,255,"%s   %s",string,nmaps[n++]) 
      while(n<6&&n<nmaps_num) 
      { 
         foundone=1 
         format(string2,255,"%s   %s",string2,nmaps[n++]) 
      } 
      if(foundone) 
         format(string3,511,"%s^n%s",string,string2) 
      else 
         format(string3,511,"%s",string) 
   } 
   hudtext16(string3,random_num(0,222),random_num(0,111),random_num(111,222),-1000,50,random_num(6,8),10,0) 
   return PLUGIN_CONTINUE 
} 
public listnominations(id) 
{ 
   new a=0,string3[512],string1[128]
   if(a<nmaps_num) 
   { 
      //show_hudmessage(id,"The following maps have been nominated for the next map vote:") 
      add(string3,511,"Maps that have been nominated for the next map vote:") 
   } 
   while(a<nmaps_num) 
   { 
      new name1[16] 
      get_user_name(whonmaps_num[a], name1, 25) 
      //set_hudmessage(255,0,0, 0.12, 0.3+0.08*float(a), 0, 15.0, 15.04, 1.5, 3.75, 2+a) 
      //show_hudmessage(id,"%s by: %s",nmaps[a],name1) 
      format(string1,128,"^n%s by: %s",nmaps[a],name1) 
      add(string3,511,string1,100)
      a++ 
   } 
   hudtext16(string3,random_num(0,222),random_num(0,111),random_num(111,222),300,10,random_num(6,8),15,id) 
} 
public messagemaps() 
{ 
   new string[256],string2[256],string3[512]
   if(quiet==2) 
      return PLUGIN_CONTINUE 
   new n 
   new total=0 
    
   if((totalmaps-6) > 0) 
      n=random_num(0,totalmaps-6) 
   else 
      n=0 
   while(total<3 && total<totalmaps && is_map_valid(listofmaps[n]) && n<totalmaps) 
   { 
      if(!islastmaps(listofmaps[n])&&!isbanned(listofmaps[n])&&!isnominated(listofmaps[n])) 
      {    
         format(string,255,"%s   %s",string,listofmaps[n]) 
         total++ 
      } 
      n++ 
   } 
   while(total<6&&n<totalmaps&&is_map_valid(listofmaps[n])&&!isnominated(listofmaps[n])) 
   { 
      if(!islastmaps(listofmaps[n])&&!isbanned(listofmaps[n])) 
      { 
         format(string2,255,"%s     %s",string2,listofmaps[n]) 
         total++ 
      } 
      n++ 
   } 
   if(total>0) 
   { 
      //show_hudmessage(0,"The following maps are available to nominate:^n%s",string) 
      add(string3,511,"The following maps are available to nominate:^n",100) 
      add(string3,511,string,100)
      add(string3,511,"^n") 
   } 
   if(total>3) 
   { 
      add(string3,511,string2,100)
   } 

   hudtext16(string3,random_num(0,222),random_num(0,111),random_num(111,222),-1000,50,random_num(6,8),10,0) 
   return PLUGIN_CONTINUE 
} 
public messagefifteen() 
{ 
   if(quiet==2){ 
      client_print(0,print_chat,"Map Voting will begin in 15 seconds!!") 
      return PLUGIN_HANDLED 
   } 
   set_hudmessage(0, 222,50, -1.0, 0.23, 1, 6.5, 6.5, 1.0, 3.0, 8)    
   show_hudmessage(0,"Map Voting will begin in 15 seconds") 
   if(quiet==0){client_cmd(0,"spk ^"get red(e80) ninety(s45) to check(e20) use bay(s18) mass(e42) cap(s50)^"")    
   } 
   set_task(8.7,"getready",459100) 
   return PLUGIN_HANDLED 

} 
public getready() 
{ 
   if(!cycle) 
      set_task(0.93,"timetovote",459200,"",0,"a",5) 
} 
public timetovote() 
{ 
   counttovote++ 
   new speak[5][] = {  "one", "two", "three", "four", "five" } 

   if(get_timeleft()>132||counttovote>5||cycle||isbuytime) 
   { 
      counttovote=0 
      remove_task(459200) 
      remove_task(459100) 
      return PLUGIN_HANDLED 
   } 
   else 
   { 
      if(counttovote>0&&counttovote<=5) 
      { 
         set_hudmessage(0, 222,50, -1.0, 0.13, 0, 1.0, 0.94, 0.0, 0.0, 8)    
         show_hudmessage(0,"Map Voting will begin in %d seconds",6-counttovote)    
         if(quiet!=1)   client_cmd(0,"spk ^"fvox/%s^"",speak[5-counttovote]) 
      } 
   } 
   return PLUGIN_HANDLED 
} 
available_maps()//return number of maps that havent that have been added yet 
{ 
   new num=0,isinlist 
   new current_map[32],a,i 
   get_mapname(current_map,31) 
   for(a=0;a<num_nmapsfill;a++) 
      if(is_map_valid(nmapsfill[a])) 
      { 
         isinlist=0 
         for(i = 0; i < nmaps_num; i++) 
            if(equali(nmapsfill[a],nmaps[i])) 
               isinlist=1 
         if(!isinlist) 
            num++ 
      } 
   return num 
} 
public askfornextmap(){  
   display_message() 
   new timeleft=get_timeleft() 
   if(isspeedset&&timeleft>30) 
   { 
      isspeedset=0 
      set_cvar_float("sv_maxspeed", thespeed) 
   } 
   if(waited>0)
   {
     return PLUGIN_HANDLED
   }
   if(timeleft>300) 
   { 
      isend=0 
      remove_task(123452) 
   } 
   new mp_winlimit = get_cvar_num("mp_winlimit") 
   if (mp_winlimit){ 
      new s=mp_winlimit-2 
      if ((s>teamscore[0]&&s>teamscore[1])&&(timeleft>114||timeleft<1)){ 
         remove_task(454500) 
         mselected = false 
         return PLUGIN_HANDLED 
      } 
   } 
   else{ 
      if(timeleft>114||timeleft<1) 
      { 
         if(timeleft>135) 
         { 
            remove_task(454510) 
            remove_task(454500) 
            remove_task(123499) 
         } 
         else 
            remove_task(454500) 
         mselected = false 
         return PLUGIN_HANDLED 
      } 
   } 
   if (inprogress||mselected||cycle) 
      return PLUGIN_HANDLED 
   mselected=false 
   inprogress=1 
   if(mp_winlimit&&!(timeleft>=115&&timeleft<134)) 
   { 
      if(quiet!=2){ 
         set_hudmessage(0, 222,50, -1.0, 0.13, 1, 6.0, 6.0, 1.0, 1.0, 8)    
         show_hudmessage(0,"Attention: Map Voting will begin in 10 seconds") 
         if(quiet!=1)   client_cmd(0,"spk ^"get red(e80) ninety(s45) to check(e20) use bay(s18) mass(e42) cap(s50)^"")    
         set_task(4.2,"getready",459100) 
         set_task(10.0,"startthevote") 
      } 
      else 
         set_task(1.0,"startthevote") 
   } 
   else 
      set_task(0.5,"startthevote") 
   return PLUGIN_HANDLED 

} 
public startthevote() 
{ 

   new mp_winlimit=get_cvar_num("mp_winlimit"), j 
   if(cycle) 
   { 
      inprogress=0 
      mselected=false 
      remove_task(459200) 
      remove_task(459100) 
      new smap[32] 
      get_cvar_string("amx_nextmap",smap,31) 
      client_print(0,print_chat,"The next map will be %s",smap) 
      return PLUGIN_HANDLED 
   } 
   for(j=0;j<maps_to_select+2;j++) 
      nvotes[j]=0 
   mselected=true 
   inprogress=1 
   counttovote=0 
   if((isbuytime||isbetween)&&get_timeleft()&&get_timeleft()>54){ 
	client_print(0,print_chat,"Voting for nextmap delayed to allow buying of weapons...") 
	if(isbetween)
	{
	      set_task(15.0,"getready",459100) 
	      set_task(21.0,"startthevote") 
	}
	else{
	      set_task(8.0,"getready",459100) 
	      set_task(14.0,"startthevote") 
	}
	return PLUGIN_HANDLED 
   }//else startthevote anyways..., regardless of buytime 
    
   remove_task(459200) 
   remove_task(459100) 
   if(quiet!=2){
	if(is_cstrike)   
		client_print(0,print_chat,"Nominations for the vote: %d out of %d possible nominations",nmaps_num,maps_to_select) 
   } 
   log_to_file(logfilename,"Nominations for the map vote: %d out of %d possible nominations",nmaps_num,maps_to_select) 
   new available 
   before_num_nmapsfill=num_nmapsfill 
   available=available_maps() 
   if((nmaps_num+available)<(maps_to_select+1))//Loads maps from mapcycle.txt/allmaps.txt if not enough are in in mapchoice.ini 
   { 
      new current_map[32] 
      get_mapname(current_map,31) 
      new overflowprotect=0 
      new used[MAX_MAPS_AMOUNT] 
      new k=num_nmapsfill 
      new totalfilled=0 
      new alreadyused 
      new tryfill,custfill=0 
      new q 
      new listpossible=totalmaps 
      while(((available_maps()+nmaps_num-custfill)<(maps_to_select+7))&&listpossible>0) 
      { 
         alreadyused=0 
         q=0 
         tryfill=random_num(0,totalmaps-1) 
         overflowprotect=0 
         while(used[tryfill]&&overflowprotect++<=totalmaps*15) 
            tryfill=random_num(0,totalmaps-1) 
         if(overflowprotect>=totalmaps*15) 
         { 
            alreadyused=1    
            log_to_file(logfilename,"Overflow detected in Map Nominate plugin, there might not be enough maps in the current vote") 
            listpossible-=1 
         } 
         else{ 
            while(q<num_nmapsfill&&!alreadyused) 
            { 
               if(equali(listofmaps[tryfill],nmapsfill[q])) 
               { 
                  alreadyused=used[tryfill]=1 
                  listpossible-- 
               } 
               q++ 
            } 
            q=0 
            while(q<nmaps_num&&!alreadyused) 
            { 
               if(equali(listofmaps[tryfill],nmaps[q])) 
               { 
                  alreadyused=used[tryfill]=1 
                  listpossible-- 
               } 
               q++ 
            } 
         } 
         if(!alreadyused) 
         { 
            if(equali(listofmaps[tryfill],current_map) || equali(listofmaps[tryfill],last_map)||
            islastmaps(listofmaps[tryfill])||isbanned(listofmaps[tryfill])) 
            { 
               listpossible-- 
               used[tryfill]=1    
            } 
            else{ 
               if(iscustommap(listofmaps[tryfill]))
                  custfill++
               nmapsfill[k]=listofmaps[tryfill] 
               num_nmapsfill++                
               listpossible-- 
               used[tryfill]=1 
               k++ 
               totalfilled++ 
            } 
         } 
      } 
      log_to_file(logfilename,"Filled %d slots in the fill maps array with maps from mapcycle.txt, %d are custom",totalfilled,custfill) 
   } 
   nbeforefill=nmaps_num//extra maps do not act as "nominations" they are additions 
   if(nmaps_num<maps_to_select) 
   { 
      new need=maps_to_select-nmaps_num 
      console_print(0,"Not enough Nominations for map vote, randomly selecting %d additional maps for the vote", need) 
      log_to_file(logfilename,"Randomly Filling slots for the vote with %d out of %d",need,num_nmapsfill) 
      new fillpossible=num_nmapsfill 
      new k=nmaps_num 
      new overflowprotect=0 
      new used[MAX_MAPS_AMOUNT] 
      new totalfilled=0,custchoice=0,full=((amt_custom+custchoice)>=maxcustnom)
      new alreadyused 
      new tryfill 
      if(num_nmapsfill<1) 
      { 
         if(quiet!=2) 
            client_print(0,print_chat,"Unable to fill any more voting slots with random maps, none defined in mapchoice.ini/mapcycle.txt/allmaps.txt") 
         log_to_file(logfilename,"ERROR: Unable to fill any more voting slots with random maps, none defined in mapchoice.ini/allmaps.txt/mapcycle.txt") 
      } 
      else       
      { 
         while(fillpossible>0&&k<maps_to_select) 
         { 
            alreadyused=0 
            new q=0 
            tryfill=random_num(0,num_nmapsfill-1) 
            overflowprotect=0 
            while(used[tryfill]&&overflowprotect++<=num_nmapsfill*10) 
               tryfill=random_num(0,num_nmapsfill-1) 
            if(overflowprotect>=num_nmapsfill*15) 
            { 
               alreadyused=1    
               log_to_file(logfilename,"Overflow detected in Map Nominate plugin, there might not be enough maps in the current vote") 
               fillpossible-=2 
            } 
            else {
               while(q<nmaps_num&&!alreadyused) 
               { 
                  if(equali(nmapsfill[tryfill],nmaps[q])) 
                  { 
                     alreadyused=used[tryfill]=1 
                     fillpossible-- 
                  } 
                  q++ 
               } 
               if(!alreadyused)
                  if(iscustommap(nmapsfill[tryfill])&&full)
                  { 
                     alreadyused=used[tryfill]=1 
                     fillpossible-- 
                  } 
            }

            if(!alreadyused) 
            { 
               if(iscustommap(nmapsfill[tryfill])){
                  custchoice++
                  full=((amt_custom+custchoice)>=maxcustnom)
               }
               nmaps[k]=nmapsfill[tryfill] 
               nmaps_num++                
               fillpossible-- 
               used[tryfill]=1 
               k++ 
               totalfilled++ 
            } 
                   
         }    
         if(totalfilled==0) 
            console_print(0,"Unable to fill any more voting slots with random maps, could not find any default maps on the server") 
         else 
            if(quiet!=2) 
               console_print(0,"Filled %d voting slots with random maps",totalfilled) 
         log_to_file(logfilename,"Filled %d vote slots with random maps, %d are custom",totalfilled,custchoice) 
      } 
   } 
   new menu[512], a, mkeys = (1<<maps_to_select+1) 
   new Float:steptime = get_cvar_float("amx_extendmap_step") 
   new extendint 
   extendint=floatround(steptime) 
   //new pos = copy(menu,511,cstrike_running ? "\yAMX Choose nextmap:\w^n^n" : "AMX Choose nextmap:^n^n") 
   //ERROR LIES BELOW cstrike_running
   new pos = copy(menu,511,(cstrike_running()==1) ? "\rChoose the next map:\w^n^n" : "Choose the next map:^n^n") 
   new dmax = (nmaps_num > maps_to_select) ? maps_to_select : nmaps_num 
   for(nmapstoch = 0;nmapstoch<dmax;++nmapstoch){ 
      a=random_num(0,nmaps_num-1) 
      while( isinmenu(a) ) 
         if (++a >= nmaps_num) a = 0 
      nnextmaps[nmapstoch] = a 
      if(iscustommap(nmaps[a])&&usestandard) 

	   if(cstrike_running()==1){
         	pos += format(menu[pos],511,"%d. %s  \b(Custom)\w^n",nmapstoch+1,nmaps[a]) 
	   }
	   else
		pos += format(menu[pos],511,"%d. %s  (Custom)^n",nmapstoch+1,nmaps[a]) 
      else 
         pos += format(menu[pos],511,"%d. %s^n",nmapstoch+1,nmaps[a]) 
      mkeys |= (1<<nmapstoch) 
      nvotes[nmapstoch] = 0 
   } 
   menu[pos++]='^n' 
   nvotes[maps_to_select] = 0 
   nvotes[maps_to_select+1] = 0    
   new mapname[32] 
   get_mapname(mapname,31) 

   if (!mp_winlimit && get_cvar_float("mp_timelimit") < get_cvar_float("amx_extendmap_max")){ 
      pos += format(menu[pos],511,"%d. Extend %s %d min.^n",maps_to_select+1,mapname,extendint) 
      mkeys |= (1<<maps_to_select) 
   } 

   format(menu[pos],511,"%d. None",maps_to_select+2) 
   show_menu(0,mkeys,menu,19) 
   set_task(20.0,"check_votes") //set_task(15.0,"check_votes") 
   if(is_cstrike)
	client_print(0,print_chat,"It's time to choose the nextmap...") 
   if(quiet==0) 
      client_cmd(0,"spk Gman/Gman_Choose%d",random_num(1,2)) 
   log_to_file(logfilename,"Vote: Voting for the nextmap started") 
   return PLUGIN_HANDLED 
} 
public handle_andchange(id,map2[]) 
{ 
   new tester[128] 
   if(is_map_valid(map2)==1) 
   { 
      handle_nominate(id,map2) 
   } 
   else 
   { 
      format(tester,31,"cs_%s",map2)     
      if(is_map_valid(tester)==1) 
         handle_nominate(id,tester) 
      else 
      { 
         format(tester,31,"de_%s",map2) 
         if(is_map_valid(tester)==1) 
            handle_nominate(id,tester) 
         else 
         { 
            format(tester,31,"as_%s",map2)    
            if(is_map_valid(tester)==1) 
               handle_nominate(id,tester)                
            else 
            { 
               format(tester,31,"dod_%s",map2)    
               if(is_map_valid(tester)==1) 
                  handle_nominate(id,tester)                
               else 
               { 
                  format(tester,31,"fy_%s",map2)    
                  if(is_map_valid(tester)==1) 
                     handle_nominate(id,tester) 
                  else 
                     handle_nominate(id,map2) 
               } 
            }                   
         } 
      } 
   }    
} 
public HandleSay(id){  

   new chat[256] 
   read_args(chat, 256) 
   new saymap[256] 
   saymap=chat 
   remove_quotes(saymap) 
   new saymap2[28] 
   read_args(saymap2,28) 
   remove_quotes(saymap2) 
   new chat2[32] 
   format(chat2,31,"cs_%s",saymap2)     
   if(containi(chat, "<")!=-1||containi(chat, "?")!=-1||containi(chat, ">")!=-1||containi(chat, "*")!=-1||containi(chat, "&")!=-1||containi(chat, ".")!=-1) 
   { 
      return PLUGIN_CONTINUE 
   } 
   if(containi(chat, "nominations") != -1) 
   { 
      if(mselected) 
         client_print(id,print_chat, "Vote in progress....") 
      else 
      if(nmaps_num==0) 
         client_print(id,print_chat, "No maps have been nominated so far, type nominate map_name to nominate a map") 
      else 
         listnominations(id) 
   } 
   else 
   if (containi(chat, "nominate ") == 1) 
   {    
      new mycommand[32] 
      read_args(mycommand,32) 
      remove_quotes(mycommand) 
      handle_andchange(id,mycommand[9])       
   } 
   else 
      if(containi(chat, "vote ") == 1) 
      { 
         new mycommand[32] 
         read_args(mycommand,32) 
         remove_quotes(mycommand) 
         handle_andchange(id,mycommand[5]) 
      } 
      else 
         if(is_map_valid(saymap)==1) 
         { 
            handle_nominate(id,saymap) 
         } 
         else 
         { 
            format(chat2,31,"cs_%s",saymap2)     
            if(is_map_valid(chat2)==1) 
               handle_nominate(id,chat2) 
            else 
            { 
               format(chat2,31,"de_%s",saymap2) 
               if(is_map_valid(chat2)==1) 
                  handle_nominate(id,chat2) 
               else 
               { 
                  format(chat2,31,"as_%s",saymap2)    
                  if(is_map_valid(chat2)==1) 
                     handle_nominate(id,chat2)                
                  else 
                  { 
                     format(chat2,31,"dod_%s",saymap2)    
                     if(is_map_valid(chat2)==1) 
                        handle_nominate(id,chat2)                
                     else 
                     { 
                        format(chat2,31,"fy_%s",saymap2)    
                        if(is_map_valid(chat2)==1) 
                           handle_nominate(id,chat2) 
                        else 
                           return PLUGIN_CONTINUE 
                     } 
                  }                   
               } 
            } 
            return PLUGIN_CONTINUE 
         }    
   return PLUGIN_CONTINUE 
} 
public calculate_custom()
{
   //New optional protection against "too many" custom maps being nominated.
   amt_custom=0
   new i
   for(i = 0; i < nmaps_num; i++) 
      if (iscustommap(nmaps[i])){ 
		amt_custom++
	}  
}
public handle_nominate(id,map[]) 
{  
   strtolower(map)
   new current_map[32],  iscust=0,iscust_t=0,full;
   full=(amt_custom>=maxcustnom)
   new n=0,i, done=0, isreplacement=0  //0: (not a replacement), 1: (replacing his own), 2: (replacing others) 
   new tempnmaps=nmaps_num 
   get_mapname(current_map,31) 
   if(inprogress&&mselected) 
   { 
      client_print(id,print_chat,"Voting is currently in progress") 
      return PLUGIN_HANDLED 
   } 
   if(mselected) 
   { 
      new smap[32] 
      get_cvar_string("amx_nextmap",smap,31) 
      client_print(id,print_chat, "Voting is now over, the next map will be %s",smap) 
      return PLUGIN_HANDLED 
   } 
   if(!is_map_valid(map)||is_map_valid(map[1])) 
   { 
      client_print(id,print_chat,"Map ^"%s^" not found on this server, type listmaps in console for a list of maps",map) 
      return PLUGIN_HANDLED 
   } 
   if(isbanned(map)) 
   { 
      client_print(id,print_chat,"Voting for that map is not currently available on this server") 
      return PLUGIN_HANDLED 
   } 
   if(islastmaps(map)&&!equali(map,current_map)) 
   { 
      client_print(id,print_chat,"You cannot nominate a map from the last %d maps played",ban_last_maps) 
      return PLUGIN_HANDLED 
   }    
   if (equali(map,current_map)) 
   { 
      client_print(id,print_chat,"This is map %s, a vote will determine whether or not the map is extended",map)  
      return PLUGIN_HANDLED 
   }   
   //Insert Strict Style code here, for cvar dmap_strict 1 
   if(get_cvar_num("dmap_strict")) 
   { 
      new isinthelist=0 
      for(new a=0; a<totalmaps;a++) 
      { 
         if(equali(map,listofmaps[a])) 
            isinthelist=1 
      } 
      if(!isinthelist){ 
         client_print(id,print_chat,"You can only nominate certain maps; say ^"listmaps^" to see a listing") 
         return PLUGIN_HANDLED 
      } 
   } 
   iscust=iscustommap(map)
   if(nmaps_num>=maps_to_select||Nominated[id]>=maxnom)//3 (1,2,3) 
   {    
      if(Nominated[id]>maxnom)//3 
      {       
         client_print(id,print_chat,"You already have nominated more than %d maps!!")//Possible to reach here! 
         //only if the command dmap_nominations is used to lower amount of maps that can be nominated 
         return PLUGIN_HANDLED     
      } 
      for(i = 0; i < nmaps_num; i++) 
         if (equali(map,nmaps[i])){ 
             
            new name[32]    
            get_user_name(whonmaps_num[i], name, 32) 
            if(quiet==2) 
               client_print(id,print_chat,"^"%s^" has already been nominated by %s",map,name) 
            else 
               client_print(0,print_chat,"^"%s^" has already been nominated by %s",map,name) 
             
            return PLUGIN_HANDLED 
         } 
      while(n<nmaps_num&&!done&&Nominated[id]>1)//If the person has nominated 2 or 3 maps, he can replace his own 
      { 
         if(whonmaps_num[n]==id)//If a map is found that he has nominated, replace his own nomination. 
         { 
		iscust_t=iscustommap(nmaps[n])
		if(!(full&&iscust&&!iscust_t))
		{
			Nominated[id]=Nominated[id]-1 
			nmaps_num=n 
			done=1
			isreplacement=1 
		}	
         } 
         n++    
      } 
      if(!done) 
      { 
         n=0 
         while(n<nmaps_num&&!done&&Nominated[id]<2)//If the person has nom only 1 or no maps, he can replace ppl who nominated 3 
         { 
		if(Nominated[whonmaps_num[n]]>2)//Replace the "greedy person's" nomination 
		{ 
			iscust_t=iscustommap(nmaps[n])
			if(!(full&&iscust&&!iscust_t))
			{
				done=1 
				Nominated[whonmaps_num[n]]=Nominated[whonmaps_num[n]]-1 
				nmaps_num=n       
				isreplacement=2 
			}
		} 
		n++ 
         } 
      }    
      if(!done) 
      { 
         n=0 
         while(n<nmaps_num&&!done&&Nominated[id]<1)//If the person has not nom any maps, he can replace those with more than one 
         {//he cannot replace those with only one nomination, that would NOT be fair 

		if(Nominated[whonmaps_num[n]]>1)//Replace the "greedy person's" nomination 
		{ 
			iscust_t=iscustommap(nmaps[n])
			if(!(full&&iscust&&!iscust_t))
			{
				done=1 
				Nominated[whonmaps_num[n]]=Nominated[whonmaps_num[n]]-1 
				nmaps_num=n 
				isreplacement=2 
			}
		}
		n++ 
	   } 
      } 
      if(!done){ 
         n=0 
         while(n<nmaps_num&&!done&&Nominated[id]>0)//If the person has nominated a map, he can replace his own 
         { 
		if(whonmaps_num[n]==id)//If a map is found that he has nominated, replace his own nomination. 
		{ 
			iscust_t=iscustommap(nmaps[n])
			if(!(full&&iscust&&!iscust_t))//Check to see if too many custom maps are nominated
			{
				Nominated[id]=Nominated[id]-1 
				nmaps_num=n 
				done=1 
				isreplacement=1
			}
		} 
		n++    
         } 
      } 
      if(!done) 
      { 
          
         client_print(id,print_chat,"Maximum number of nominations has been reached (%d)",nmaps_num)     
         return PLUGIN_HANDLED 
      } 
   } 
   for(i = 0; i < nmaps_num; i++) 
      if (equali(map,nmaps[i])){ 
         new name[32]    
         get_user_name(whonmaps_num[i], name, 32) 
         client_print(id,print_chat,"Map ^"%s^" has already been Nominated by %s",map,name) 
         nmaps_num=tempnmaps 
         return PLUGIN_HANDLED 
      } 
   if(!isreplacement&&iscust&&full)
   {
      client_print(id,print_chat,"%d custom maps have been nominated so far, no more may be nominated",maxcustnom) 
      return PLUGIN_HANDLED 
   }
   new name[32]    
   get_user_name(id, name, 21) 
   if(isreplacement==1)//They are replacing their old map 
      if(quiet==2) 
         client_print(id, print_chat, "Your previous nomination of ^"%s^" has been replaced",nmaps[nmaps_num]) 
      else 
         client_print(0, print_chat, "%s has replaced his nomination of ^"%s^"",name,nmaps[nmaps_num])    
   else   if(isreplacement==2) 
         if(quiet==2) 
            client_print(0,print_chat, "The previous nomination of ^"%s^" has now been replaced",nmaps[nmaps_num]) 
         else{ 
            new name21[32]    
            get_user_name(whonmaps_num[nmaps_num], name21, 31) 
            client_print(0,print_chat, "%s's nomination of ^"%s^" has now been replaced",name21,nmaps[nmaps_num]) 
         }    
   Nominated[id]++ 
   console_print(id,"Adding %s to map nomination slot %d",map,nmaps_num+1)
   set_task(0.18,"calculate_custom")
   copy(nmaps[nmaps_num],31,map) 
   whonmaps_num[nmaps_num]=id 
   if(isreplacement) 
      nmaps_num=tempnmaps    
   else 
      nmaps_num=tempnmaps+1    
   client_print(0,print_chat,"%s has nominated map %s, say ^"nominations^" to see a list",name,map) 
   return PLUGIN_HANDLED 
} 
public team_score(){  
   new team[2] 
   read_data(1,team,1) 
   teamscore[ (team[0]=='C') ? 0 : 1 ] = read_data(2) 
   return PLUGIN_CONTINUE 
} 

public plugin_end(){ 
   new current_map[32] 
   get_mapname(current_map,31) 
   set_localinfo("amx_lastmap",current_map) 
   if(istimeset) 
      set_cvar_float("mp_timelimit",oldtimelimit) 
   else
	if(istimeset2)
         set_cvar_float("mp_timelimit",get_cvar_float("mp_timelimit")-2.0)
   if(isspeedset) 
      set_cvar_float("sv_maxspeed",thespeed) 
   if(iswinlimitset) 
      set_cvar_num("mp_winlimit",oldwinlimit)
   return PLUGIN_CONTINUE 
} 
public get_listing() 
{ 
   new i=0, iavailable=0 
   new line=0,p 
   new stextsize = 0 , isinthislist=0, found_a_match=0 , done=0
   new linestr[256] 
   new maptext[32] 
   new current_map[32] 
   get_mapname(current_map,31) 
   pathtomaps="mapcycle.txt" 
   new smap[32] 
   get_cvar_string("amx_nextmap",smap,31) 
   if (file_exists(pathtomaps))
   {
      while(read_file(pathtomaps,line,linestr,255,stextsize)&&!done) 
      { 
         format(maptext,31,"%s",linestr) 
         if(is_map_valid(maptext)&&!is_map_valid(maptext[1])&&equali(maptext,current_map)) 
         { 
            done=found_a_match=1 
            line++ 
            if(read_file(pathtomaps,line,linestr,255,stextsize)) 
            { 
               format(maptext,31,"%s",linestr) 
               if(is_map_valid(maptext)&&!is_map_valid(maptext[1])) 
               { 
                  ////////////////////////////////////////// 
                  if(equali(smap,"")) 
                     register_cvar("amx_nextmap","",FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY) 
                  set_cvar_string("amx_nextmap",maptext) 		
               } 
               else
               found_a_match=0 
            }
            else
               found_a_match=0  
         } 
         else 
            line++ 
      }
	/*
      if(!found_a_match)
      {
		line=0
		while(read_file(pathtomaps,line,linestr,255,stextsize)&&!found_a_match&&line<1024)
		{
			format(maptext,31,"%s",linestr)
			if(is_map_valid(maptext)&&!is_map_valid(maptext[1]))
			{
				if(equali(smap,"")) 
				   register_cvar("amx_nextmap","",FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY) 				
				set_cvar_string("amx_nextmap",maptext) 
				found_a_match=1
			}
			else
				line++
		}
	}
	*/
	/* CODE TO RANDOMIZE NEXTMAP VARIABLE!*/
      if(!found_a_match)
      {
		line=random_num(0,50)
		new tries=0

		while((read_file(pathtomaps,line,linestr,255,stextsize)||!found_a_match)&&(tries<1024&&!found_a_match))
		{
			format(maptext,31,"%s",linestr)
			if(is_map_valid(maptext)&&!is_map_valid(maptext[1]))
			{
				if(equali(smap,"")) 
				   register_cvar("amx_nextmap","",FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY) 				
				set_cvar_string("amx_nextmap",maptext) 
				found_a_match=1
			}
			else{
				line=random_num(0,50)
				tries++
			}
		}
	}
	

   }
   line=0 
   format(pathtomaps,64,"%s/allmaps.txt",custompath)
   /* Doesn't work on linux
   if (!file_exists(pathtomaps)){
	new mapsadded=0
	while ( read_dir( "maps" ,line++ ,linestr,255,stextsize) )
	{
		stextsize -= 4

		if (stextsize > 0)
		{
			if ( !equali( linestr[stextsize] , ".bsp" ) )
 				continue // skip non map files

			linestr[stextsize] = 0 // remove .bsp
		}

		if ( is_map_valid(  linestr  ))
		{
 			write_file( pathtomaps , linestr )
 			mapsadded++
		}

	}
	log_to_file(logfilename,"Found %d maps in your <mod>/MAPS folder, and added these to the addons/amxmodx/allmaps.txt file",mapsadded)
	line=0
   }
   */

   if(get_cvar_float("dmap_strict")==1.0) 
      pathtomaps="mapcycle.txt" 
    
   if (file_exists(pathtomaps)) 
      while(read_file(pathtomaps,line,linestr,255,stextsize)&&i<MAX_MAPS_AMOUNT) 
      { 
         format(maptext,31,"%s",linestr) 
         if(is_map_valid(maptext)&&!is_map_valid(maptext[1])) 
         { 
            isinthislist=0 
            for(p=0;p<i;p++) 
               if(equali(maptext,listofmaps[p])) 
                  isinthislist=1 
            if(!isinthislist) 
               listofmaps[i++]=maptext          
         } 
         line++ 
      } 
   line=0 
   for(p=0;p<i;p++) 
      if(!isbanned(listofmaps[p])&&!islastmaps(listofmaps[p])) 
         iavailable++ 
   if(iavailable<maps_to_select&&!equali(pathtomaps,"mapcycle.txt")) 
   { 
      pathtomaps="mapcycle.txt" 
      if (file_exists(pathtomaps)) 
         while(read_file(pathtomaps,line,linestr,255,stextsize)&&i<MAX_MAPS_AMOUNT) 
         { 
            format(maptext,31,"%s",linestr) 
            if(is_map_valid(maptext)&&!is_map_valid(maptext[1])){ 
               isinthislist=0 
               for(p=0;p<i;p++) 
                  if(equali(maptext,listofmaps[p])) 
                     isinthislist=1 
               if(!isinthislist) 
                  listofmaps[i++]=maptext 
            } 
            line++ 
         }       
   } 
   totalmaps=i       
   iavailable=0 
   for(p=0;p<i;p++) 
      if(!isbanned(listofmaps[p])&&!islastmaps(listofmaps[p])) 
         iavailable++ 

   log_to_file(logfilename,"Found %d Maps in your mapcycle.txt/allmaps.txt file, %d are available for filling slots",i,iavailable) 
} 
public ban_some_maps() 
{ 
   //BAN MAPS FROM CONFIG FILE
   new banpath[64] 
   format(banpath,64,"%s/_deagles_map_manage/mapstoban.ini",custompath) 
   new i=0 
   new line=0 
   new stextsize = 0 
   new linestr[256] 
   new maptext[32] 
    
   if (file_exists(banpath)) 
      while(read_file(banpath,line,linestr,255,stextsize)&&i<MAX_MAPS_AMOUNT) 
      { 
         format(maptext,31,"%s",linestr) 
         if(is_map_valid(maptext)&&!is_map_valid(maptext[1])) 
            banthesemaps[i++]=maptext 
         line++ 
      } 
   totalbanned=i 
   if(totalbanned>0) 
      log_to_file(logfilename,"Banned %d Maps in your mapstoban.ini file",totalbanned) 
   else 
      log_to_file(logfilename,"Did not ban any maps from mapstoban.ini file") 
   //BAN RECENT MAPS PLAYED
   new lastmapspath[64]
   format(lastmapspath,64,"%s/lastmapsplayed.txt",custompath) 
   //new linestring[32] 
   line=stextsize = 0 
   new current_map[32] 
   get_mapname(current_map,31) 
   lastmaps[0]=current_map 
   bannedsofar++ 
   currentplayers=activeplayers=rocks=0 
   if (file_exists(lastmapspath)) 
   { 
      while(read_file(lastmapspath,line,linestr,255,stextsize)&&bannedsofar<=ban_last_maps){ 
         if((strlen(linestr) > 0)&&(is_map_valid(linestr))){    
            format(lastmaps[bannedsofar++],31,"%s",linestr) 
            //copy(lastmaps[bannedsofar++],31,"%s",linestr) 
         } 
         line++ 
      } 
   } 
   write_lastmaps();//deletes and writes to lastmapsplayed.txt
} 
public write_lastmaps()
{
   new lastmapspath[64]
   format(lastmapspath,64,"%s/lastmapsplayed.txt",custompath) 
   if (file_exists(lastmapspath)) 
      delete_file(lastmapspath) 
   new text[256],p 
   for(p=0;p<bannedsofar;p++) 
   { 
      format(text,255,"%s",lastmaps[p]) 
      write_file(lastmapspath,text) 
   } 
   write_file(lastmapspath,"Generated by map_nominate plugin,") 
   write_file(lastmapspath,"these are most recent maps played") 

   load_maps();

}
public load_maps() 
{ 
   new choicepath[64] 
   format(choicepath,64,"%s/mapchoice.ini",custompath) 
   new line=0 
   new stextsize = 0 ,isinlist,unable=0, i 
   new linestr[256] 
   new maptext[32] 
   new current_map[32] 
   get_mapname(current_map,31) 
   if (file_exists(choicepath)){ 
      while( read_file(choicepath,line,linestr,255,stextsize) && (num_nmapsfill<MAX_MAPS_AMOUNT) ) 
      { 
         format(maptext,31,"%s",linestr) 
         if (is_map_valid(maptext)&&!is_map_valid(maptext[1])){ 
            isinlist=0 
            if(isbanned(maptext)||islastmaps(maptext)) 
               isinlist=1 
            else 
            if (equali(maptext,current_map) || equali(maptext,last_map)) 
               isinlist=1 
            else 
               for(i = 0; i < num_nmapsfill; i++) 
                  if (equali(maptext,nmapsfill[i])){ 
                     log_to_file(logfilename,"Map ^"%s^" is already in list! It is defined it twice",maptext) 
                     isinlist=1 
                  } 
            if(!isinlist) 
               copy(nmapsfill[num_nmapsfill++],31,maptext) 
            else 
               unable++ 
         } 
         line++ 
      } 
      log_to_file(logfilename,"Loaded %d Maps into the maps that will be picked for the vote",num_nmapsfill)  
      log_to_file(logfilename,"%d Maps were not loaded because they were the last maps played, or defined twice, or banned",unable)  
   } 
   else 
      log_to_file(logfilename,"Unable to open file %s, In order to get maps: your mapcycle.txt file will be searched",choicepath) 
   get_listing();
} 
public load_defaultmaps() 
{  
   new standardpath[64]
   format(standardpath,64,"%s/standardmaps.ini",custompath) 
   new i=0 
   new line=0 
   new stextsize = 0 
   new linestr[256] 
   new maptext[32] 
   usestandard=1 
   if (!file_exists(standardpath)) 
      usestandard=standardtotal=0 
   else{ 
      while(read_file(standardpath,line,linestr,255,stextsize)&&i<40) 
      { 
         format(maptext,31,"%s",linestr) 
         if(is_map_valid(maptext)) 
            standard[i++]=maptext 
         line++ 
      } 
      standardtotal=i 
   } 
   if(standardtotal<5) 
   { 
      usestandard=0 
      log_to_file(logfilename,"Attention, %d Maps were found in the standardmaps.ini file. This is no problem, but the words Custom will not be used",standardtotal)     
   } 
} 
bool:iscustommap(map[]) 
{ 
   new a 
   for(a=0;a<standardtotal;a++) 
      if(equali(map,standard[a])) 
         return false 
   if(usestandard) 
      return true 
   return false 
} 
bool:islastmaps(map[]) 
{ 
   new a 
   for(a=0;a<bannedsofar;a++) 
      if(equali(map,lastmaps[a])) 
         return true 
   return false 
} 
bool:isnominated(map[]) 
{ 
   new a 
   for(a=0;a<nmaps_num;a++) 
      if(equali(map,nmaps[a])) 
         return true 
   return false 
} 
bool:isbanned(map[]) 
{ 
   new a 
   for(a=0;a<totalbanned;a++) 
      if(equali(map,banthesemaps[a])) 
         return true 
   return false 
} 
loadsettings(filename[]) 
{ 
   if (!file_exists(filename)) 
      return 0 
       
   new text[256],percent[5],strban[4],strplay[3],strwait[3],strwait2[3],strurl[64], strnum[3], strnum2[3] 

   new len, pos = 0 
   new Float:numpercent 
   new banamount,nplayers,waittime,mapsnum 
   while (read_file(filename,pos++,text,255,len)) 
   { 
      if ( text[0] == ';' ) continue 
      switch(text[0]){ 
         case 'r':{ 
             
            format(percent,4,"%s",text[2]) 
            numpercent=float(strtonum(percent))/100.0 
            if(numpercent>=0.03&&numpercent<=1.0) 
               rtvpercent=numpercent 
         } 
         case 'q':{ 
            if(text[1]=='2') 
               quiet=2 
            else 
               quiet=1 
         } 
         case 'c':{ 
            cycle=1 
         } 
         case 'd':{ 
            enabled=0 
         } 
         case 'f':{ 
            if(text[1]=='r'){ 
               format(strwait2,2,"%s",text[2]) 
               waittime=strtonum(strwait2) 
               if(waittime>=2&&waittime<=20) 
                  frequency=waittime 
            } 
            else 
               dofreeze=0 
         } 
         case 'b':{ 
            format(strban,3,"%s",text[2]) 
            banamount=strtonum(strban) 
            if(banamount>=0&&banamount<=100) 
               if((banamount==0&&text[2]=='0')||banamount>0) 
                  ban_last_maps=banamount 
         } 
         case 'm':{ 
            if(atstart){ 
               format(strnum,2,"%s",text[2]) 
               mapsnum=strtonum(strnum) 
               if(mapsnum>=2&&mapsnum<=8) 
                  maps_to_select=mapssave=mapsnum 
            } 
         } 
         case 'p':{ 
            format(strplay,2,"%s",text[2]) 
             
            nplayers=strtonum(strplay) 
            if(nplayers>0&&nplayers<=32) 
               minimum=nplayers 
         } 
         case 'u':{ 
            format(strurl,63,"%s",text[2]) 
            if((containi(strurl,"www")!=-1||containi(strurl,"http")!=-1)&&!equali(strurl,"http")) 
               mapsurl=strurl 
         } 
         case 'w':{ 
            format(strwait,2,"%s",text[2]) 
             
            waittime=strtonum(strwait) 
            if(waittime>=5&&waittime<=30) 
               minimumwait=waittime 
         } 
         case 'x':{ 
            format(strnum2,2,"%s",text[2]) 
             
            mapsnum=strtonum(strnum2) 
            if(mapsnum>=1&&mapsnum<=3) 
               maxnom=mapsnum 
         } 

         case 'y':{ 
            format(strnum2,2,"%s",text[2]) 
             
            mapsnum=strtonum(strnum2) 
            if(mapsnum>=0&&mapsnum<=mapssave) 
               maxcustnom=mapsnum 
         } 

      }       
   }    
   return 1 
} 
set_defaults(myid) 
{ 
   rtvpercent=0.6 
   ban_last_maps=4 
   maxnom=frequency=3
   quiet=cycle=0 
   minimum=enabled=1 
   minimumwait=10 
   mapssave=maxcustnom=5 
   mapsurl="" 
   dofreeze=cstrike_running()==1 
   if(myid>=0) 
      savesettings(myid) 
   else 
      savesettings(-1) 
   if(myid>=0){ 
      showsettings(myid) 
      console_print(myid,"==================   DEFAULTS SET   =========================")    
   } 
} 
public dmaprtvpercent(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   new arg[32] 
   read_argv(1,arg,3) 
   new Float:percentage 
   percentage=float(strtonum(arg))/100.0    
   if(percentage>=0.03&&percentage<=1.0) 
   { 
      rtvpercent=percentage 
      savesettings(id) 
      showsettings(id) 
   } 
   else{ 
      console_print(id,"You must specify a value between 3 and 100 for dmap_rtvpercent")    
      console_print(id,"This sets minimum percent of players that must say rockthevote to rockit") 
   } 
   return PLUGIN_HANDLED    
} 
public dmaprtvplayers(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   new arg[32] 
   read_argv(1,arg,3) 
   new players 
   players=strtonum(arg)    
   if(players>=1&&players<=32) 
   { 
      minimum=players 
      savesettings(id) 
      showsettings(id) 
   } 
   else{ 
      console_print(id,"You must specify a value between 1 and 32 for dmap_rtvplayers")    
      console_print(id,"This sets minimum num of players that must say rockthevote to rockit") 
   } 
   return PLUGIN_HANDLED 
    
} 
public dmaprtvwait(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   new arg[32] 
   read_argv(1,arg,3) 
   new wait 
   wait=strtonum(arg)    
   if(wait>=5&&wait<=30) 
   { 
      minimumwait=wait 
      savesettings(id) 
      showsettings(id) 
   } 
   else{ 
      console_print(id,"You must specify a value between 5 and 30 for dmap_rtvwait")    
      console_print(id,"This sets how long must pass from the start of map before players may rockthevote") 
   } 
   return PLUGIN_HANDLED 
    
} 
public dmapmessages(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   new arg[32] 
   read_argv(1,arg,3) 
   new wait 
   wait=strtonum(arg)    
   if(wait>=2&&wait<=20) 
   { 
      frequency=wait 
      savesettings(id) 
      showsettings(id) 
   } 
   else{ 
      console_print(id,"You must specify a value between 2 and 20 minutes for dmap_messages")    
      console_print(id,"This sets how many minutes will pass between messages for nominations for available maps") 
   } 
   return PLUGIN_HANDLED 
    
} 
public dmapmapsnum(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   new arg[32] 
   read_argv(1,arg,3) 
   new maps 
   maps=strtonum(arg)    
   if(maps>=2&&maps<=8) 
   { 
      mapssave=maps 
      savesettings(id) 
      showsettings(id) 
      console_print(id,"*****  Settings for dmap_mapsnum do NOT take effect until the next map!!! ******") 
   } 
   else{ 
      console_print(id,"You must specify a value between 2 and 8 for dmap_mapsnum")    
      console_print(id,"This sets the # of maps in the vote, changing this doesn't take effect until the next map") 
   } 
   return PLUGIN_HANDLED 
    
} 
public dmapmaxnominations(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   new arg[32] 
   read_argv(1,arg,3) 
   new thisnumber 
   thisnumber=strtonum(arg)    
   if(thisnumber>=1&&thisnumber<=3) 
   { 
      maxnom=thisnumber 
      savesettings(id) 
      showsettings(id) 
      console_print(id,"*****  Settings for dmap_nominations do NOT take effect until the next map!!! ******") 
   } 
   else{ 
      console_print(id,"You must specify a value between 1 and 3 for dmap_nominations")    
      console_print(id,"This sets the maximum number of maps a person can nominate") 
   } 
   return PLUGIN_HANDLED 
    
} 
public dmapmaxcustom(id) 
{
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   new arg[32] 
   read_argv(1,arg,3) 
   new thisnumber 
   thisnumber=strtonum(arg)    
   if(thisnumber>=0&&thisnumber<=mapssave) 
   { 
      maxcustnom=thisnumber 
      savesettings(id) 
      showsettings(id) 
   } 
   else{ 
      console_print(id,"You must specify a value between {0} and maximum maps in the vote, which is {%d}, for dmap_maxcustom",mapssave)    
      console_print(id,"This sets the maximum number of custom maps that may be nominated by the players") 
   } 
   return PLUGIN_HANDLED 
    
} 
public dmapquiet(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   new arg[32] 
   read_argv(1,arg,31) 
   if(containi(arg, "off")!=-1){ 
      console_print(id,"======Quiet mode is now OFF, messages pertaining to maps will be shown=====") 
      quiet=0 
   }else 
   if(containi(arg, "silent")!=-1){ 
      console_print(id,"======Quiet mode is now set to SILENT, A minimal amount of messages will be shown!=====") 
      quiet=2 
   }else 
   if(containi(arg, "nosound")!=-1){ 
      console_print(id,"======Quiet mode is now set to NOSOUND, messages pertaining to maps will be shown, with no sound=====") 
      quiet=1 
   }else 
   {console_print(id,"USAGE: dmap_quietmode <OFF|NOSOUND|SILENT>") 
   return PLUGIN_HANDLED 
   } 
   savesettings(id) 
   showsettings(id) 
   return PLUGIN_HANDLED 
} 
public dmaprtvtoggle(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   if(enabled==0) 
      console_print(id,"=========Rockthevote is now enabled==============") 
   else 
      console_print(id,"=========Rockthevote is not disabled=================") 
   enabled=!enabled 
   savesettings(id) 
   showsettings(id) 
   return PLUGIN_HANDLED 
} 
public changefreeze(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   if (!(cstrike_running()==1)){ 
      console_print(id,"Freeze is always off on non-Counter Strike Servers") 
      return PLUGIN_HANDLED 
   } 
   new arg[32] 
   read_argv(1,arg,31) 
   if(containi(arg, "off")!=-1){ 
      console_print(id,"=========FREEZE/Weapon Drop at end of round is now disabled==============") 
      dofreeze=0 
   } 
   else 
   if(containi(arg, "on")!=-1){ 
      console_print(id,"=========FREEZE/Weapon Drop at end of round is now enabled==============") 
      dofreeze=1 
   } 
   else{ 
      console_print(id,"========= USAGE of dmap_freeze: dmap_freeze on|off (this will turn freeze/weapons drop at end of round on/off") 
      return PLUGIN_HANDLED 
   } 
   savesettings(id) 
   showsettings(id) 
   return PLUGIN_HANDLED 
} 
public dmapcyclemode(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   if(!cycle){ 
      console_print(id,"=========     Cylce mode is now ON, NO VOTE will take place!   =========") 
   } 
   else{ 
      console_print(id,"=========     Cycle Mode is already on, no change is made   =========") 
      console_print(id,"=========     If you are trying to enable voting, use command dmap_votemode") 
      return PLUGIN_HANDLED 
   } 
   cycle=1 
   savesettings(id) 
   showsettings(id) 
   if(inprogress) 
   { 
      console_print(id,"=========     The Vote In Progress cannot be terminated, unless it hasn't started!   =========") 
   } 
   return PLUGIN_HANDLED 
} 
public dmapvotemode(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   if(cycle) 
      console_print(id,"=========     Voting mode is now ON, Votes WILL take place   =========")    
   else{ 
      console_print(id,"=========     Voting mode is already ON, no change is made   =========") 
      console_print(id,"=========     If you are trying to disable voting, use command dmap_cyclemode") 
      return PLUGIN_HANDLED 
   } 
   cycle=0 
   savesettings(id) 
   showsettings(id) 
   return PLUGIN_HANDLED 
} 
public dmapbanlastmaps(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   new arg[32] 
   read_argv(1,arg,4) 
   new banamount 
   banamount=strtonum(arg)    
   if(banamount>=0&&banamount<=99) 
   { 
      if(banamount>ban_last_maps) 
      { 
         console_print(id,"You have choosen to increase the number of banned maps") 
         console_print(id,"Changes will not take affect until the nextmap; maps played more than %d maps ago will not be included in the ban",ban_last_maps) 
      } 
      else 
         if(banamount<ban_last_maps) 
            console_print(id,"You have choosen to decrease the number of banned maps") 
      ban_last_maps=banamount 
      savesettings(id) 
      showsettings(id) 
   } 
   else{ 
      console_print(id,"You must specify a value between 0 and 99 for dmap_banlastmaps") 
      console_print(id,"dmap_banlastmaps <n> will ban the last <n> maps from being voted/nominated")    
   } 
   return PLUGIN_HANDLED 
    
} 
public dmaphelp(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      new myversion[32] 
      get_cvar_string("Deags_Map_Manage",myversion,31) 
      console_print(id,"*****This server uses the plugin Deagles NextMap Management %s *****",myversion) 
      console_print(id,"") 
      if(cycle){ 
         console_print(id,"===================  The plugin is set to cycle mode.  No vote will take place   =================") 
         return PLUGIN_HANDLED 
      } 
      console_print(id,"Say ^"vote mapname^" ^"nominate mapname^" or just simply ^"mapname^" to nominate a map") 
      console_print(id,"") 
      console_print(id,"Say ^"nominations^" to see a list of maps already nominated.") 
      console_print(id,"Say ^"listmaps^" for a list of maps you can nominate") 
      console_print(id,"Number of maps for the vote at the end of this map will be: %d",maps_to_select)
      console_print(id,"Players may nominate up to %d maps for the vote (dmap_nominations)",maxnom)
      console_print(id,"Players may nominate up to %d **Custom** maps for the vote (dmap_maxcustom)",maxcustnom) 
      if(enabled) { 
         console_print(id,"Say ^"rockthevote^" to rockthevote") 
         console_print(id,"In order to rockthevote the following 3 conditions need to be true:") 
         console_print(id,"%d percent of players must rockthevote, and at least %d players must rockthevote",floatround(rtvpercent*100.0),minimum) 
         console_print(id,"Vote may not be rocked before %d minutes have elapsed on the map",minimumwait) 

      } 
      if(containi(mapsurl,"www")!=-1||containi(mapsurl,"http")!=-1) 
         console_print(id,"You can download Custom maps at %s (dmap_mapsurl)",mapsurl) 
      return PLUGIN_HANDLED 
   } 
   //For CS 1.6, the following MOTD will display nicely, for 1.5, It will show html tags. 
   client_print(id,print_chat,"loading motd window on to your computer") 
   showmotdhelp(id) 
    
   return PLUGIN_HANDLED 
} 
public gen_maphelphtml(){ 
   new path[64],text[128] 
   format(path,63,"%s/map_manage_help.htm",custompath) 
   if(file_exists(path)) 
      delete_file(path) 
   format(text,127,"This Map Management Plugin allows easy nominations of maps for users,") 
   write_file(path,text) 
   format(text,127,"and gives<br>the admins much control over the voting process.") 
   write_file(path,text) 
   format(text,127,"<br><br>When in Voting mode, all the players need to do to nominate a map is say the name of it in chat.") 
   write_file(path,text) 
   format(text,127,"<br>Usage of dmap_votemode/dmap_cyclemode by admins will either enable voting mode, or cycle mode.") 
   write_file(path,text) 
   format(text,127,"<br>When in cycle mode, maps cannot be nominated, and the next map in the mapcycle will be the next map.") 
   write_file(path,text) 
   format(text,127,"<br><br>The last (N) number of maps cannot be voted for.  To change this, use dmap_banlastmaps") 
   write_file(path,text) 
   format(text,127,"<br><font color=red> For further help and description of commands, please visit</font>") 
   write_file(path,text) 
   format(text,127,"<A href=http://djeyl.net/forum/index.php?showtopic=28679&st=0>the following web page</a>") 
   write_file(path,text) 
} 
public showmotdhelp(id) 
{ 
   new header[80] 
   new myversion[32] 
   new helpfile[60]
   format(helpfile,60,"%s/map_manage_help.htm",custompath)
   get_cvar_string("Deags_Map_Manage",myversion,31) 
   format ( header , 79 ,"Deagles' Map Management Version %s Help",myversion ) 
   if(!file_exists(helpfile)) 
      gen_maphelphtml() 
   show_motd(id,helpfile,header) 

} 
public dmapstatus(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   showsettings(id) 
   return PLUGIN_CONTINUE 
} 
showsettings(id) 
{ 
   console_print(id,"-----------------------------------------------------------------------------------------------") 
   console_print(id,"                 Status of Deagles Map Management Version 2.30b") 
   if(cycle){ 
      console_print(id,"===================  Mode is Cycle Mode NO vote will take place   =================") 
      console_print(id,"===================  To enable voting use command dmap_votemode   ===================") 
   } 
   else{ 
      console_print(id,"=======================  Current Mode is Voting Mode   ===============================") 
      if(quiet==2) 
         console_print(id,"Quiet Mode is set to SILENT.  Minimal text messages will be shown, no sound will be played  (dmap_quietmode)") 
      else{    
         if(quiet==1) 
            console_print(id,"Quiet Mode is set to NOSOUND.  Text messages will be shown, with no sound.  (dmap_quietmode)") 
         else 
            console_print(id,"Quiet Mode is OFF, messages will be shown with sound (dmap_quietmode)") 
         console_print(id,"The time between messages about maps is %d minutes (dmap_messages)",frequency) 
      } 
      console_print(id,"The last %d Maps played will not be in the vote (changing this will not start until the Next Map)",ban_last_maps) 
      if(maps_to_select!=mapssave) 
         console_print(id,"Number of maps for the vote on this map is: %d (Next Map it will be: %d)",maps_to_select,mapssave) 
      else 
         console_print(id,"Number of maps for the vote at the end of this map will be: %d (dmap_mapsnum)",maps_to_select) 
      console_print(id,"Players may nominate up to %d maps each for the vote (dmap_nominations)",maxnom)
      console_print(id,"Players may nominate up to %d **Custom** maps each for the vote (dmap_maxcustom)",maxcustnom)
      if(get_cvar_num("enforce_timelimit"))
      {
      	console_print(id,"^"Timeleft^" will be followed to change the maps, not allowing players to finish the round")
      	console_print(id,"To change this, ask your server admin to set the cvar ^"enforce_timelimit^" to 0")
      }
      if(enabled==0) 
         if(!get_cvar_num("mp_timelimit")) 
            console_print(id,"rockthevote is disabled since mp_timelimit is set to 0") 
         else 
            console_print(id,"rockthevote is disabled; (dmap_rtvtoggle)") 
      console_print(id,"In order to rockthevote the following 3 conditions need to be met:") 
      console_print(id,"%d percent of players must rockthevote, and at least %d players must rockthevote",floatround(rtvpercent*100.0),minimum) 
      console_print(id,"Vote may not be rocked before %d minutes have elapsed on the map (10 is recommended)",minimumwait) 
   } 
   console_print(id,"The Freeze/Weapons Drop at the end of the round is %s (dmap_freeze)",dofreeze?"ENABLED":"DISABLED") 
   if(!usestandard) 
      console_print(id,"Custom will not be shown by any maps, since file standardmaps.ini is not on the server") 
   else 
      console_print(id,"The words custom will be shown by Custom maps") 
   if(containi(mapsurl,"www")!=-1||containi(mapsurl,"http")!=-1) 
      console_print(id,"URL to download Custom maps is %s (dmap_mapsurl)",mapsurl) 
   else 
      console_print(id,"URL to download maps from will not be shown (dmap_mapsurl)") 
   console_print(id,"------------------------------------------------------------------------------------------------") 
   console_print(id,"Commands     : dmap_status; dmap_cyclemode; dmap_votemode; dmap_quietmode <OFF|NOSOUND|SILENT>; ") 
   console_print(id,"Commands     : dmap_banlastmaps <n>; dmap_default ; dmap_mapsurl <url>; dmap_mapsnum <n>; dmap_maxcustom <n>;") 
   console_print(id,"Commands     : dmap_rtvtoggle; dmap_rtvpercent <n>; dmap_rtvplayers <n>; dmap_rtvwait <n>") 
   console_print(id,"Commands     : dmap_rockthevote; dmap_freeze; dmap_nominations <n>; dmap_messages <n(minutes)>") 
   console_print(id,"Cvars:         dmap_strict <0|1>, enforce_timelimit <0|1>; amx_extendmap_max <n>; amx_extendmap_step <n>")
   console_print(id,"-------------------------   use command dmap_help for more information   -----------------------") 
} 
change_custom_path(){
	new temp[64],bool:dir_exists=true
	format(temp,64,"%s/_deagles_map_manage/standardmaps.ini",custompath)
	if(!file_exists(temp)){
		format(temp,64,"%s/_deagles_map_manage/mapchoice.ini",custompath)
		if(!file_exists(temp)){
			format(temp,64,"%s/_deagles_map_manage/mapvault.dat",custompath)
			if(!file_exists(temp))
				dir_exists=false
		}
	}
	if(dir_exists)
		format(custompath,48,"%s/dmap",custompath)

}
savesettings(myid) 
{ 

   new settings[64]
   format(settings,64,"%s/mapvault.dat",custompath) 
   if (file_exists(settings)) 
      delete_file(settings) 
   new text[32],text2[128],percent,success=1,usedany=0 
   format(text2,127,";To use comments simply use ;") 
   if(!write_file(settings,text2)) 
      success=0 
   format(text2,127,";Do not modify this variables, this is used by the Nomination_style_voting plugin to save settings") 
   if(!write_file(settings,text2)) 
      success=0 
   format(text2,127,";If you delete this file, defaults will be restored.") 
   if(!write_file(settings,text2)) 
      success=0 
   format(text2,127,";If you make an invalid setting, that specific setting will restore to the default")  
   if(!write_file(settings,text2)) 
      success=0 
   if(!enabled)    
   { 
      format(text,31,"d")//d for disabled 
      usedany=1 
      if(!write_file(settings,text)) 
         success=0 
   } 
   if(quiet!=0) 
   { 
      if(quiet==1) 
         format(text,31,"q1")//d for disabled 
      else 
         format(text,31,"q2")//d for disabled 
          
      usedany=1 
      if(!write_file(settings,text)) 
         success=0 
   } 
   if(!dofreeze||!(cstrike_running()==1)) 
   { 
      format(text,31,"f") 
      if(!write_file(settings,text)) 
         success=0 
   } 
   if(cycle) 
   { 
      format(text,31,"c")//c for Cycle mode=on 
      usedany=1 
      if(!write_file(settings,text)) 
         success=0 
   } 
   percent=floatround(rtvpercent*100.0) 
   if(percent>=3&&percent<=100) 
   { 
      format(text,31,"r %d",percent) 
      usedany=1 
      if(!write_file(settings,text)) 
         success=0 
   }    
   if(ban_last_maps>=0&&ban_last_maps<=100) 
   { 
      format(text,31,"b %d",ban_last_maps) 
      usedany=1 
      if(!write_file(settings,text)) 
         success=0 
   }    
   if(mapssave>=2&&mapssave<=8) 
   { 
      format(text,31,"m %d",mapssave) 
      usedany=1 
      if(!write_file(settings,text)) 
         success=0 
   } 
   if(maxnom>=1&&maxnom<=3) 
   { 
      format(text,31,"x %d",maxnom) 
      usedany=1 
      if(!write_file(settings,text)) 
         success=0 
   } 
   if(maxcustnom>=0&&maxcustnom<=mapssave) 
   { 
      format(text,31,"y %d",maxcustnom) 
      usedany=1 
      if(!write_file(settings,text)) 
         success=0 
   } 
   if(minimum>0&&minimum<=32) 
   { 
      format(text,31,"p %d",minimum) 
      usedany=1 
      if(!write_file(settings,text)) 
         success=0 
   } 
   if(minimumwait>=5&&minimumwait<=30) 
   { 
      format(text,31,"w %d",minimumwait) 
      usedany=1 
      if(!write_file(settings,text)) 
         success=0 
   } 
   if(frequency>=2&&frequency<=20) 
   { 
      format(text,31,"fr %d",frequency) 
      usedany=1 
      if(!write_file(settings,text)) 
         success=0 
   } 
   if(containi(mapsurl,"www")!=-1||containi(mapsurl,"http")!=-1) 
   { 
      format(text2,75,"u %s",mapsurl) 
      usedany=1 
      if(!write_file(settings,text2)) 
         success=0       
   } 
   if(usedany) 
   { 
      if(myid>=0) 
         if(success) 
            console_print(myid,"*********   Settings saved successfully    *********") 
         else 
            console_print(myid,"Unable to write to file %s",settings) 
      if(!success) 
      { 
         log_to_file(logfilename,"Unable to write to file %s",settings)          
         return 0 
      } 
   }    
   else 
   { 
      if(myid>=0) 
         console_print(myid,"Variables not valid, not saving to %s",settings) 
      log_to_file(logfilename,"Warning: Variables not valid, not saving to %s",settings) 
      return 0 
   } 
   return 1 
} 
public dmapmapsurl(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   new arg[64] 
   read_argv(1,arg,63) 
   if(equali(arg,"http")) 
   { 
      console_print(id,"You must specify a url that contains www or http (do not use any colons)(use ^"none^" to disable)") 
      return PLUGIN_HANDLED 

   } 
   if(containi(arg,"www")!=-1||containi(arg,"http")!=-1) 
   { 
      console_print(id,"You have changed the mapsurl to %s",arg) 
      mapsurl=arg 
      savesettings(id) 
      showsettings(id) 
   } 
   else 
   { 
      if(containi(arg,"none")!=-1){ 
         console_print(id,"You have choosen to disable your mapsurl, none will be used") 
         mapsurl="" 
         savesettings(id) 
         showsettings(id) 
      } 
      else 
         console_print(id,"You must specify a url that contains www or http (do not use any colons)(use ^"none^" to disable)") 
   } 
   return PLUGIN_HANDLED 
} 
public dmapdefaults(id) 
{ 
   if (!(get_user_flags(id)&ADMIN_MAP)){ 
      console_print(id,"You have no access to that command") 
      return PLUGIN_HANDLED 
   } 
   set_defaults(id) 
   return PLUGIN_HANDLED 

} 

public event_RoundStart() 
{ 
	isbetween=0
	isbuytime=1 
	set_task(10.0, "now_safe_to_vote") 
} 
public event_RoundEnd() 
{ 
	isbetween=1
} 
public now_safe_to_vote(){ 
   //client_print(0,print_chat,"Now it is safe to vote") 
   isbuytime=0 
} 
public list_maps2(){
	messagemaps()
}
public list_maps3(){
	messagenominated()
}
public plugin_init(){ 
   register_plugin("DeagsMapManage","2.30b","Deags") 
   get_customdir(custompath,49);
   change_custom_path();
   register_clcmd("say","HandleSay",0,"Say: vote mapname, nominate mapname, or just mapname to nominate a map, say: nominations") 
   register_clcmd( "say rockthevote", "rock_the_vote", 0, "Rocks the Vote" ) 
   register_clcmd("say listmaps","list_maps",0,"Lists all maps in a window and in console") 
   //register_clcmd("say listmaps2","list_maps2",0,"Displays message of which maps can be nominated!")
   //register_clcmd("say listmaps3","list_maps3",0,"Displays message of which maps have been nominated!")
   register_clcmd("say nextmap","say_nextmap",0,"Shows nextmap information to players") 
   register_clcmd("listmaps","list_maps",0,"Lists all maps in a window and in console") 
   register_concmd("dmap_help","dmaphelp",0,"Shows on-screen help information about Map Plugin") 
   register_concmd("dmap_status","dmapstatus",ADMIN_MAP,"Shows settings/status/help of the map management variables") 
   register_concmd("dmap_votemode","dmapvotemode",ADMIN_MAP,"Enables Voting (This is default mode)") 
   register_concmd("dmap_cyclemode","dmapcyclemode",ADMIN_MAP,"Disables Voting (To restore voting use dmap_votemode)") 
   register_concmd("dmap_banlastmaps","dmapbanlastmaps",ADMIN_MAP,"Bans the last <n> maps played from being voted (0-99)") 
   register_concmd("dmap_quietmode","dmapquiet",ADMIN_MAP,"Usage: <OFF|nosound|silent>") 
   register_concmd("dmap_freeze","changefreeze",ADMIN_MAP,"Toggles Freeze/Drop at end of round ON|off") 
   register_concmd("dmap_messages","dmapmessages",ADMIN_MAP,"Sets the time interval in minutes between messages") 
   register_concmd("dmap_rtvtoggle","dmaprtvtoggle",ADMIN_MAP,"Toggles on|off Ability of players to use rockthevote") 
   register_concmd("dmap_rockthevote","admin_rockit",ADMIN_MAP,"(option: now) Allows admins to force a vote") 
   register_concmd("dmap_rtvpercent","dmaprtvpercent",ADMIN_MAP,"Set the percent (3-100) of players for a rtv") 
   register_concmd("dmap_rtvplayers","dmaprtvplayers",ADMIN_MAP,"Sets the minimum number of players needed to rockthevote") 
   register_concmd("dmap_rtvwait","dmaprtvwait",ADMIN_MAP,"Sets the minimum time before rockthevote can occur (5-30)") 
   register_concmd("dmap_default","dmapdefaults",ADMIN_MAP,"Will restore settings to default") 
   register_concmd("dmap_mapsurl","dmapmapsurl",ADMIN_MAP,"Specify what website to get custom maps from") 
   register_concmd("dmap_mapsnum","dmapmapsnum",ADMIN_MAP,"Set number of maps in next vote (will not take effect until next map") 
   register_concmd("dmap_nominations","dmapmaxnominations",ADMIN_MAP,"Set maximum number of nominations for each person") 
   register_concmd("dmap_maxcustom","dmapmaxcustom",ADMIN_MAP,"Set maximum number of custom nominations that may be made") 

   register_logevent("event_RoundStart",2,"0=World triggered","1=Round_Start") 
   register_logevent("event_RoundEnd",2,"0=World triggered","1=Round_End") 
   register_event( "30" , "changeMap", "a" )
   get_time("maplog%m%d.log",logfilename,255)    
   register_cvar("rtv_percent","0.6") 
   register_cvar("dmap_strict","0") 
   register_cvar("amx_extendmap_max","90") 
   register_cvar("amx_extendmap_step","15") 
   new mod_name[32] 
   get_modname(mod_name,31) 
   //cstrike_running = equal(mod_name,"cstrike") ? true : false 
   is_cstrike=(cstrike_running()==1)
   nmaps_num=num_nmapsfill=0 
   if (cstrike_running()==1){ 
      register_cvar("Deags_Map_Manage", "2.30b",FCVAR_SERVER) 
      register_event("TeamScore", "team_score", "a") 
      register_cvar("enforce_timelimit","0")

   } 
   else{ 
      dofreeze=0 
      register_cvar("Deags_Map_Manage", "2.30b") 
      register_cvar("enforce_timelimit","0")
   
   } 
   rtvpercent=0.6 
   ban_last_maps=4 
   minimumwait=10 
   atstart=enabled=minimum=1 
   quiet=cycle=isend=0 
   mapsurl="" 
   set_task(3.0,"ban_some_maps")//reads from lastmapsplayed.txt and stores into global array
   //set_task(8.0,"write_lastmaps")//deletes and writes to lastmapsplayed.txt
   //set_task(2.0,"get_listing")//loads mapcycle / allmaps.txt
   set_task(14.0,"load_defaultmaps") //loads standardmaps.ini
   //set_task(17.0,"load_maps") //loads mapchoice.ini
   set_task(15.0,"askfornextmap",987456,"",0,"b") 
   set_task(5.0,"loopmessages",987111,"",0,"b") 
   set_task(34.0,"gen_maphelphtml")//Writes to help file, which is read every time that dmap_help is called by ANY player 
   oldtimelimit=get_cvar_float("mp_timelimit") 
   get_localinfo("amx_lastmap",last_map,31) 
   set_localinfo("amx_lastmap","") 
   maps_to_select=mapssave=5 
   new temparray[64]
   format(temparray,64,"%s/mapvault.dat",custompath)
   if(!loadsettings(temparray)) 
      set_defaults(-1) 
   atstart=0 
   register_menucmd(register_menuid("Choose the next map:"),(-1^(-1<<(maps_to_select+2))),"vote_count")

   return PLUGIN_CONTINUE 
} 
