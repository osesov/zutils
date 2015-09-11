#! /usr/bin/gawk -f

func die(msg, a, b, c, d, e, f)
{
    printf( msg, a, b, c, d, e, f )
    printf( "\nat (%d): %s\n", NR, $0 )
    exit(1);
}

function time2str(year, mon, day, hour, min, sec, msec)
{
    return sprintf("%02d.%02d.%04d %02d:%02d:%02d.%03d", day, mon, year, hour, min, sec, msec);
}

function time2ts( year, mon, day, hour, min, sec, msec )
{
    return								\
	( int( ( 1461 * ( year + 4800 + int( ( mon - 14 ) / 12) ) ) / 4) + \
	  int( ( 367 * ( mon - 2 - 12 * int( ( mon - 14 ) / 12) ) ) / 12) - \
	  int( ( 3 * ( ( year + 4900 +  int( ( mon - 14 ) / 12) ) / 100 ) ) / 4) + \
	  day - 32075 )							\
	* (24 * 60 * 60 * 1000) + (((hour * 60 + min) * 60 + sec) * 1000 + msec)
}

function ts2time( jd, r,			\
		  l, n, j, d, m, y )
{
    l = int(jd / (24 * 60 * 60 * 1000) ) + 68569
    n = int( ( 4 * l ) / 146097)
    l = l - int( ( 146097 * n + 3 ) / 4)
    i = int( ( 4000 * ( l + 1 ) ) / 1461001 )
    l = l - int( ( 1461 * i ) / 4 ) + 31
    j = int( ( 80 * l ) / 2447 )
    d = l - int( ( 2447 * j ) / 80 )
    l = int( j / 11 )
    m = j + 2 - ( 12 * l )
    y = 100 * ( n - 49 ) + i + l

    r[0] = y
    r[1] = m
    r[2] = d

# convert time
    l = jd % (24 * 60 * 60 * 1000)

    r[6] = l % 1000; l = int(l / 1000)
    r[5] = l % 60;   l = int(l / 60)
    r[4] = l % 60;   l = int(l / 60)
    r[3] = l % 24;   l = int(l / 24)
}

function ts2str( tm,				\
		 _d)
{
    delete _d
    ts2time( tm, _d )
    return time2str(_d[0], _d[1], _d[2], _d[3], _d[4], _d[5], _d[6]);
}

# converts to epoch time
function _str2time(str \
		  , _arr, _day, _mon, _year, _hour, _min, _sec, _msec, _ts)
{
    if (match(str, /([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+) ([[:digit:]]+)\:([[:digit:]]+)\:([[:digit:]]+)(\.([[:digit:]]+))?/, _arr)) {

	_ts = time2ts( _arr[3], _arr[2], _arr[1], _arr[4], _arr[5], _arr[6], _arr[8] );
#	g0 = ts2str( _ts );
#	g1 = time2str( _arr[3], _arr[2], _arr[1], _arr[4], _arr[5], _arr[6], _arr[8] );
	
#	if (g0 != g1)
#	    die( "Unvalid time. orig: '%s', parsed '%s', '%s'", str, g0, g1 );
	return _ts;
    }

    die( "unable to parse time [%s]", str);
}

function gettime(date, time)
{
    return _str2time( date " " time);
}

# time measure

function print_arr(arr, \
		   _col, _index)
{

	for (_index = 0; _index < length(p); ++_index) {
#	for (_index in p) {
		if (_index != 0)
			printf(",")
		printf("%s", arr[p[_index]])
		_col++;
	}
	printf("\n");
}

function print_header()
{
	print_arr( title );

	delete avg
	averages = 0;
}

function print_stats()
{
	if (!start[boot])
		return

	printf("%d)", boot_index )
	print_arr( time );

# update average
	for (i in title) {
		avg[i] = avg[i] + time[i];
	}
	averages++;

#    printf("%s\t%s\t%s\n", dal_time, powerup_time, ready_to_watch_time)
#    start[boot] = 0;
}

function print_final()
{
	print_stats();

	print "---";
	if (averages) {
		for (i in title) {
			avg[i] = int(avg[i] / averages);
		}
	}

	print_arr( avg )

	delete avg
	averages = 0;
}

function begin_boot()
{
	if (state != none) {
		state=none
		delete start
		boot_index++;
		fixtime = 0;

		delete start
		delete time
		close( out );
		out = FILENAME ".part" boot_index ".log";
		printf("") > out;
#		print "BOOT: " boot_index ")", $0
	}
}

BEGINFILE {

# indices
	first = -1
	none = 0
	boot = 1
	dal  = 2
	powerup = 3
	ready_to_watch = 4

	platform=100

# titles
	title[ boot ] = ""
	title[ dal  ] = "dal"
	title[ powerup ] = "powerup"
	title[ ready_to_watch ] = "ready_to_watch"
	title[ platform ] = "Platform"

# print
	p[0] = dal
	p[1] = powerup
	p[2] = platform
	p[3] = ready_to_watch

# env
	state = first
	fixtime = 0;
	boot_index = 0;
	start[boot] = 0;

	print "*** " FILENAME;
	print_header();
}


# line time is in $2 and $3
# [DBG] 13.08.2015 06:04:16.501
/BCM74130011|main: starting supervisor/ {  # first supervisor message, reset stage
	begin_boot();
}

!start[ boot ] && /\[SUPERVISOR\]/ {
    begin_boot();
    start[ boot ] = gettime($2, $3)
    state = boot
#    print "SUPERVISOR: ", $0
#    print "start: " start[boot], ts2str(start[boot]), $0;
}

#!start[dal] && /\[DalManager\]/ {
/DAL: main: DAL version/ { # first DAL message
    if (!start[boot]) {
	print "no start message found"
	next;
    }

    start[dal] = gettime($2, $3) - fixtime
    time[dal]  = start[dal] - start[boot]
    state = dal
}

/DAL: PosixProcess::run: run \[powerup-launcher\]/ {
    if (!start[boot]) {
	print "no start message found"
	next;
    }

    start[powerup] = gettime($2, $3) - fixtime
    time[powerup] = start[powerup] - start[dal]
    state = powerup
}

/Registry: set: \[registry\] ready_to_watch <-- 1 \[added, 0\]/ {
    if (!start[boot]) {
	print "no start message found"
	next;
    }

    start[ready_to_watch] = gettime($2, $3) - fixtime
    time[ready_to_watch] = start[ready_to_watch] - start[powerup]
    state = ready_to_watch

    print_stats();
}

/LifeCycleManager: initialization of the component DOB2 complete/ {
    now = gettime($2, $3) - fixtime
    time[ platform ] = now - start[ powerup ]
}

/system time changed from .* to .*/ { # time fix message
	if (!start[boot])
		next

	if (!match($0, /system time changed from (.*) to (.*)/, arr))
		die("Unable to match time");

	delta1 = gettime(arr[1])
	delta2 = gettime(arr[2])
	fixtime += (delta2 - delta1)
}

ENDFILE {
	print_final()
	close( out );
}

{
	if (start[boot]) {
		print $0 >> out;
	}
}
