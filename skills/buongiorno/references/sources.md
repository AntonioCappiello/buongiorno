# Finding and testing sources

Test every source with `scripts/check_feeds.py` before putting it in the prompt. A feed
that worked once can be blocked from cloud IP addresses, so prefer sources that respond
to a plain `curl` with a browser User-Agent.

## Where to look

1. **National public broadcasters**: they usually publish RSS per topic and region
   (e.g. BBC, NOS, ANSA, Rai, DW, France Info, RTVE). Search "<broadcaster> RSS".
2. **Regional and local papers**: try `<site>/feed/`, `<site>/rss`, `<site>/rss.xml`,
   `<site>/feed`. WordPress sites almost always answer on `/feed/`.
3. **Google News search RSS**: the trick for small towns, companies and niche topics.
   ```
   https://news.google.com/rss/search?q=<query>&hl=<lang>&gl=<COUNTRY>&ceid=<COUNTRY>:<lang>
   ```
   - Exact phrase: `q=%22San+Gimignano%22`
   - Several towns: `q=Hallstatt+OR+%22Bad+Ischl%22+OR+Gosau`
   - One outlet that blocks direct fetches: `q=site:example.it` (if that returns 0 items, drop the outlet)
   - Always add a time filter (`+when:1d`, `+when:7d`, `+when:30d`): without it, results can be years old.
   - Small, niche queries are noisy: the same query can return different items an hour later. Give them a wider window (7-30 days) and rely on the memory repo to avoid repeats.
   Titles end with " - Source name": use that as the source. Links are Google redirects:
   they open fine for the reader, but the routine can't follow them (consent page /
   JavaScript), so it should web-search the headline to read the original. Item dates are
   when Google indexed a story, not always when it happened (an old match result can look
   new). Sports queries also return betting and odds sites: tell the agent to ignore them.
   There are no images.
   For town names that are also common words (e.g. "Bath", "Reading", "Nice"), use
   phrases (`%22in+Bath%22`), the demonym, or town + region (this happens in every
   language: a town's name can be an ordinary word), and tell the agent to keep
   only items clearly about the place. Percent-encode accents (ñ = `%C3%B1`); the checker
   script does this for you.
   Women's and youth teams often share a name with the men's first team: add a strict
   filter line in the prompt ("only items about the women's team").
4. **Industry**: trade blogs, platform developer news (Apple Developer news RSS, Android
   Developers blog), newsletters with RSS (many Substack/Ghost/Beehiiv publications have
   `/feed`), Hacker News via `https://hnrss.org/frontpage?points=300`.
5. **Sport**: national sport feeds (BBC Sport, NOS Sport, Gazzetta), specialist sites
   (Cyclingnews, Runner's World), team news via Google News queries.

## Free data APIs (no key needed)

| Need | API |
|---|---|
| Geocoding a place to lat/lon | `https://geocoding-api.open-meteo.com/v1/search?name=<place>&count=5&language=en`: pick the result whose `country_code` and `admin1` match (the first result can be in the wrong country). Write the coordinates into the prompt; never geocode at run time. |
| Weather + hourly forecast | `https://api.open-meteo.com/v1/forecast?latitude=..&longitude=..&hourly=temperature_2m,precipitation_probability,precipitation,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,wind_speed_10m_max,sunrise,sunset&timezone=<tz>&forecast_days=2` (occasionally overloaded: retry, or use a national fallback such as Buienradar in NL) |
| Pollen and air quality (Europe) | `https://air-quality-api.open-meteo.com/v1/air-quality?latitude=..&longitude=..&hourly=alder_pollen,birch_pollen,grass_pollen,mugwort_pollen,olive_pollen,ragweed_pollen,european_aqi&timezone=<tz>&forecast_days=2` (grains/m³; near zero out of season, which is normal) |
| City open data (roadworks, closures, transport) | Many cities publish free JSON/WFS portals (search "<city> open data"). Some transport APIs need a free account: treat its key as a secret. Pages that only render with JavaScript can't be read by the routine. |
| Official weather warnings | Europe: Meteoalarm feeds (search "meteoalarm <country> rss"); UK: Met Office warnings RSS by region; Poland: IMGW `https://danepubliczne.imgw.pl/api/data/warningsmeteo` (filter by county code). An empty feed means no warnings. |
| Exchange rates | ECB: `https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml` |
| EU unemployment | Eurostat `une_rt_m` JSON API |
| Euro mortgage rates | ECB MIR: `https://data-api.ecb.europa.eu/service/data/MIR/M.<CC>.B.A2C.A.R.A.2250.EUR.N?lastNObservations=2&format=csvdata` |
| US data | FRED CSV without key: `https://fred.stlouisfed.org/graph/fredgraph.csv?id=UNRATE` (or `MORTGAGE30US`) |
| Earthquakes | USGS: `https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&latitude=..&longitude=..&maxradiuskm=150&minmagnitude=2.5&starttime=..`; Italy: INGV `https://webservices.ingv.it/fdsnws/event/1/query?...&format=text` |
| App competitors | iTunes Search API `https://itunes.apple.com/search?term=..&entity=software&country=..` (rate-limited: wait 10-15 s between calls) |

Calendars (events, races, conferences) usually have no feed: the agent finds them with
web search on listing sites, then confirms dates and prices on official pages. Tell it to
mark anything taken only from a third-party listing.

## Known problems

- **403 Forbidden** from news sites in the cloud: switch to a Google News `site:` query.
- **Malformed XML**: tell the fetch script to strip control characters and stray `&` and retry.
- **Reddit** blocks automated access almost everywhere; don't plan around it.
- **Stale feeds**: a feed that answers but whose newest item is many months old is dead.
  The checker's "STALE?" flag (over 14 days) is a hint, not a verdict: a blog that posts
  monthly can still be a good source with a long window.
- **Calendars**: events rarely have feeds. During setup, find listing pages (federation
  or club calendars, regional agendas, venue and ticket pages) and write them into the
  prompt; an agent searching from nothing every morning usually finds nothing confirmed.
- **Paywalls**: headlines and summaries in the feed are fine; don't try to fetch full articles.
- **Too much**: 40-80 feeds is plenty. More feeds mean longer runs, not a better brief.

## Show the user

For the smallest places, print 5-10 recent titles from their feed so the user sees what
they'll get. Ask if anything is missing (a neighbouring town, a local outlet they read).
