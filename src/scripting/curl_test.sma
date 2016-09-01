#include <amxmodx>
#include <curl>

#define CURL_BUFFER_SIZE 512

enum _:CURLData
{
	curl_slist:CURLHeaders,
	CURLBuffer[512]
};

public plugin_init()
{
	register_plugin("CURL test", "1.0", "pvab");
	set_task(5.0, "CheckRecordFake");
}

public CheckRecordFake()
{
	new type_id = 1;
	new authid[] = "STEAM_0:0:8756497";

	new CURL:curl = curl_easy_init();

	if (curl) {
		new APIHost[] = "dev.kz-endo.com";
		new APIPath[] = "/api2/expanded_full_ranked_records";

		new map[32];
		get_mapname(map, 31);

		new url[192];
		formatex(url, 191, "https://%s%s?type_id=eq.%d&map=eq.%s&authid=eq.%s", APIHost, APIPath, type_id, map, authid);

		log_amx(url);

		new data[CURLData];

		data[CURLHeaders] = curl_slist_append(data[CURLHeaders], "Accept: text/csv");

		curl_easy_setopt(curl, CURLOPT_HTTPHEADER, data[CURLHeaders]);
		curl_easy_setopt(curl, CURLOPT_BUFFERSIZE, CURL_BUFFER_SIZE);
		curl_easy_setopt(curl, CURLOPT_URL, url);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, data);
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, "write_callback");

		curl_easy_perform(curl, "curl_complete", data);
	} else {
		log_amx("curl init error");
	}
}

public write_callback(chunk[], size, nmemb, data[CURLData])
{
	new actual_size = size * nmemb;
	copy(data[CURLBuffer], charsmax(data[CURLBuffer]), chunk);
	return actual_size;
}

public curl_complete(CURL:curl, CURLcode:code, data[CURLData])
{
	if (code == CURLE_OK) {
		log_amx("data: %s", data[CURLBuffer]);
	} else {
		new err[256];
		curl_easy_strerror(code, err, strlen(err));
		log_amx("curl error: %s", err);
	}

	curl_slist_free_all(data[CURLHeaders]);
	curl_easy_cleanup(curl);
}
