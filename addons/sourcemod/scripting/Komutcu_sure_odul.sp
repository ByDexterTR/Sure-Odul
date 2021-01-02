#include <sourcemod>
#include <warden>
#include <clientprefs>
#include <store>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "KOMUTÇU SÜRE ÖDÜL", 
	author = "ByDexter", 
	description = "Komutçu Süre Ödül", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

ConVar g_Sure = null, g_Odul = null;
Handle g_Cookie = null, h_timer = null;

public void OnPluginStart()
{
	g_Cookie = RegClientCookie("Dexter-KomSure", "Aptalliga care yok demis atalarimiz", CookieAccess_Protected);
	g_Sure = CreateConVar("sm_kom_odul_sure", "31", "X ödülünü almak için kaç dakika oynama süresi olması gerekir?", 0, true, 1.0);
	g_Odul = CreateConVar("sm_kom_odul_kredi", "500", "X dakikasına ulaştığını kaç kredi ödül almalıdır?", 0, true, 1.0);
	RegConsoleCmd("sm_komodul", Command_Makose, "sm_komodul");
	RegConsoleCmd("sm_komsurem", Command_Malose, "sm_komsurem");
	
	AddCommandListener(Listener_UnWarden, "sm_uw");
	AddCommandListener(Listener_UnWarden, "sm_unwarden");
	AddCommandListener(Listener_UnWarden, "sm_uc");
	AddCommandListener(Listener_UnWarden, "sm_uncommander");
	AutoExecConfig(true, "KomSure-Odul", "ByDexter");
}

/*
** Bu kadar kolay bir şey için database açan cahil herif QWD:QWD:
** ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
*/

public void warden_OnWardenCreated(int client)
{
	char sBuffer[512];
	GetClientCookie(client, g_Cookie, sBuffer, sizeof(sBuffer));
	if (strcmp(sBuffer, "", false) == 0)
	{
		SetClientCookie(client, g_Cookie, "0");
	}
	if (h_timer != null)
		delete h_timer;
	h_timer = CreateTimer(60.0, Dakikaplus, GetClientUserId(client), TIMER_REPEAT);
}

public Action Listener_UnWarden(int client, const char[] command, int argc)
{
	if (warden_iswarden(client))
	{
		if (h_timer != null)
		{
			delete h_timer;
			h_timer = null;
		}
	}
}

public void warden_OnWardenRemoved(int client)
{
	if (h_timer != null)
	{
		delete h_timer;
		h_timer = null;
	}
}

public Action Dakikaplus(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (IsClientInGame(client) && IsClientConnected(client) && warden_iswarden(client))
	{
		char sBuffer[512];
		GetClientCookie(client, g_Cookie, sBuffer, sizeof(sBuffer));
		FormatEx(sBuffer, sizeof(sBuffer), "%d", StringToInt(sBuffer) + 1);
		SetClientCookie(client, g_Cookie, sBuffer);
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

/*
** ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
** Bu kadar kolay bir şey için database açan cahil herif QWD:QWD:
*/

public Action Command_Makose(int client, int args)
{
	char sBuffer[512];
	GetClientCookie(client, g_Cookie, sBuffer, sizeof(sBuffer));
	if (StringToInt(sBuffer) >= g_Sure.IntValue)
	{
		ReplyToCommand(client, "[SM] \x04Tebrikler, \x01sunucumuzda vakit geçirdiğin için \x04%d kredi \x01kazandın.", g_Odul.IntValue);
		Store_SetClientCredits(client, Store_GetClientCredits(client) + g_Odul.IntValue);
		FormatEx(sBuffer, sizeof(sBuffer), "%d", StringToInt(sBuffer) - g_Sure.IntValue);
		SetClientCookie(client, g_Cookie, sBuffer);
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[SM] \x01Ödül almak için \x04%d Dakika \x01daha oynamalısın :C", g_Sure.IntValue - StringToInt(sBuffer));
		return Plugin_Handled;
	}
}

public Action Command_Malose(int client, int args)
{
	char sBuffer[512];
	GetClientCookie(client, g_Cookie, sBuffer, sizeof(sBuffer));
	if (StringToInt(sBuffer) >= g_Sure.IntValue)
	{
		ReplyToCommand(client, "[SM] \x01Ödül alabilirsin, \x01!odul");
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[SM] \x01Ödül almak için \x04%d Dakika \x01daha oynamalısın :C", g_Sure.IntValue - StringToInt(sBuffer));
		return Plugin_Handled;
	}
} 