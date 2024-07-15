# myMPD last.fm scrobbler
Scrobble tracks from myMPD to last.fm

Triggers:  

Trigger name: lastfm_player  
Event: Player (mpd_player)  
Script: lastfm  
Scrips arguments: trigger=player  

Trigger name: lastfm_scrobble  
Event: Scrobble (mympd_scrobble)  
Script: lastfm  
Scrips arguments: trigger=scrobble  

Trigger name: lastfm_feedback  
Event: Feedback (mympd_feedback)  
Script: lastfm  
Scrips arguments: trigger=feedback  

To get session key launch script lastfm.lua with argument trigger=key  
