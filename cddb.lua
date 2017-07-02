local ffi = require("ffi")
local libcddb = ffi.load('libcddb')
ffi.cdef[[
int printf(const char *fmt, ...);
]]
ffi.cdef[[
typedef enum {
    CDDB_CAT_DATA = 0,          /**< data disc */
    CDDB_CAT_FOLK,              /**< folk music */
    CDDB_CAT_JAZZ,              /**< jazz music */
    CDDB_CAT_MISC,              /**< miscellaneous, use if no other
                                     category matches */
    CDDB_CAT_ROCK,              /**< rock and pop music */
    CDDB_CAT_COUNTRY,           /**< country music */
    CDDB_CAT_BLUES,             /**< blues music */
    CDDB_CAT_NEWAGE,            /**< new age music */
    CDDB_CAT_REGGAE,            /**< reggae music */
    CDDB_CAT_CLASSICAL,         /**< classical music */
    CDDB_CAT_SOUNDTRACK,        /**< soundtracks */
    CDDB_CAT_INVALID,           /**< (internal) invalid category */
    CDDB_CAT_LAST               /**< (internal) category counter */
} cddb_cat_t;

/** Actual definition of track structure. */
struct cddb_track_s
{
    int num;                    /**< track number on the disc */
    int frame_offset;           /**< frame offset of the track on the disc */
    int length;                 /**< track length in seconds */
    char *title;                /**< track title */
    char *artist;               /**< (optional) track artist */
    char *ext_data;             /**< (optional) extended disc data */
    struct cddb_track_s *prev;  /**< pointer to previous track, or NULL */
    struct cddb_track_s *next;  /**< pointer to next track, or NULL */
    struct cddb_disc_s *disc;   /**< disc of which this is a track */
};

typedef struct cddb_track_s cddb_track_t;

/** Actual definition of disc structure. */
struct cddb_disc_s
{
    unsigned int revision;      /**< revision number */
    unsigned int discid;        /**< four byte disc ID */
    cddb_cat_t category;        /**< CDDB category */
    char *genre;                /**< disc genre */
    char *title;                /**< disc title */
    char *artist;               /**< disc artist */
    unsigned int length;        /**< disc length in seconds */
    unsigned int year;          /**< (optional) disc year YYYY */
    char *ext_data;             /**< (optional) extended disc data  */
    int track_cnt;              /**< number of tracks on the disc */
    cddb_track_t *tracks;       /**< pointer to the first track */
    cddb_track_t *iterator;     /**< track iterator */
};

typedef struct cddb_conn_s cddb_conn_t;
typedef struct cddb_disc_s cddb_disc_t;

cddb_conn_t *cddb_new(void);
void cddb_set_server_name(cddb_conn_t *c, const char *server);
void cddb_set_server_port(cddb_conn_t *c, int port);
void cddb_set_timeout(cddb_conn_t *c, unsigned int t);
void cddb_set_http_path_query(cddb_conn_t *c, const char *path);
void cddb_set_http_path_submit(cddb_conn_t *c, const char *path);
void cddb_http_enable(cddb_conn_t *c);




cddb_disc_t *cddb_disc_new(void);
void cddb_disc_set_length(cddb_disc_t *disc, unsigned int l);
void cddb_disc_add_track(cddb_disc_t *disc, cddb_track_t *track);
unsigned int cddb_disc_get_year(const cddb_disc_t *disc);
const char *cddb_disc_get_title(const cddb_disc_t *disc);
const char *cddb_disc_get_artist(const cddb_disc_t *disc);
void cddb_disc_print(cddb_disc_t *disc);





cddb_track_t *cddb_track_new(void);
void cddb_track_set_frame_offset(cddb_track_t *track, int offset);


int cddb_query(cddb_conn_t *c, cddb_disc_t *disc);
int cddb_read(cddb_conn_t *c, cddb_disc_t *disc);
int cddb_query_next(cddb_conn_t *c, cddb_disc_t *disc);


]]

local track_offsets = {
  150,
  27573,
  50976,
  72477,
  92180,
  116636,
  142887,
  164443,
  186361,
  203621,
}
local disc_length = 2996

--local track_offsets = {
--150, 28690, 51102, 75910, 102682, 121522,
--    149040, 175772, 204387, 231145, 268065}
--local disc_length = 3822

local conn = ffi.new("cddb_conn_t*[1]")
conn[0] = libcddb.cddb_new()
conn = conn[0]
libcddb.cddb_http_enable(conn)
libcddb.cddb_set_server_port(conn, 80)
libcddb.cddb_set_server_name(conn, "vgmdb.net")
libcddb.cddb_set_http_path_query(conn, "/cddb")
print("hello")
--libcddb.cddb_set_server_name(conn, "freedb.org")
print("hello")
--libcddb.cddb_set_http_path_query(conn, "/~cddb/cddb.cgi")
--libcddb.cddb_set_http_path_submit(conn, "/~cddb/submit.cgi")
print("hello")

local disc = ffi.new("cddb_disc_t*[1]")
disc[0] = libcddb.cddb_disc_new()
disc = disc[0]
print("hello")
libcddb.cddb_disc_set_length(disc, disc_length)
print("hello")

for i=1, #track_offsets do
  print("track "..i)
  local track = ffi.new("cddb_track_t*[1]")
  track[0] = libcddb.cddb_track_new()
  track = track[0]
  libcddb.cddb_track_set_frame_offset(track, track_offsets[i])
  libcddb.cddb_disc_add_track(disc, track)
end

print("hi")
matches = libcddb.cddb_query(conn, disc)

print("found "..matches.." match" .. (match ~= 1 and "" or "es"))
--if true then return end

ffi.C.printf("My disc: %s UGUU %s", disc.genre, disc.discid)

for i=1,matches do
  success = libcddb.cddb_read(conn, disc)
  print("success "..success)
  if success ~= 0 then
    libcddb.cddb_disc_print(disc)
  end

  if i < matches then
    huh = libcddb.cddb_query_next(conn, disc)
    print("huh "..huh)
  end
end
