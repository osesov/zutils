#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <fcntl.h>
#include <assert.h>
#include <ctype.h>
#include <stddef.h>

#ifdef _MSC_VER
# include <io.h>
typedef unsigned __int16 UINT16;
typedef unsigned __int32 ULONG32;
typedef unsigned __int64 ULONG64;
typedef unsigned __int32 RVA;
#else
# include <stdint.h>

typedef uint16_t UINT16;
typedef uint32_t ULONG32;
typedef uint64_t ULONG64;
typedef uint32_t RVA;

#endif

#ifdef unix
# include <unistd.h>
# include <inttypes.h>
#endif

#ifndef O_BINARY
# define O_BINARY 0
#endif

//#define I32 ""
#define L32x PRIx32
#define L32d PRId32
#define L32u PRIu32

#define L64d PRId64
#define L64u PRIu64
#define L64x PRIx64

typedef struct _MINIDUMP_HEADER {
  ULONG32 Signature;
  ULONG32 Version;
  ULONG32 NumberOfStreams;
  RVA     StreamDirectoryRva;
  ULONG32 CheckSum;
  union {
    ULONG32 Reserved;
    ULONG32 TimeDateStamp;
  };
  ULONG64 Flags;
} MINIDUMP_HEADER;

typedef struct _MINIDUMP_LOCATION_DESCRIPTOR {
  ULONG32 DataSize;
  RVA     Rva;
} MINIDUMP_LOCATION_DESCRIPTOR;

typedef struct _MINIDUMP_DIRECTORY {
  ULONG32                      StreamType;
  MINIDUMP_LOCATION_DESCRIPTOR Location;
} MINIDUMP_DIRECTORY;

typedef struct _MINIDUMP_MEMORY_DESCRIPTOR {
  ULONG64                      StartOfMemoryRange;
  MINIDUMP_LOCATION_DESCRIPTOR Memory;
} MINIDUMP_MEMORY_DESCRIPTOR;

typedef struct _MINIDUMP_MEMORY_LIST {
  ULONG32                    NumberOfMemoryRanges;
//  MINIDUMP_MEMORY_DESCRIPTOR MemoryRanges[1];
} MINIDUMP_MEMORY_LIST;

typedef struct _MINIDUMP_THREAD {
  ULONG32                      ThreadId;
  ULONG32                      SuspendCount;
  ULONG32                      PriorityClass;
  ULONG32                      Priority;
  ULONG64                      Teb;
  MINIDUMP_MEMORY_DESCRIPTOR   Stack;
  MINIDUMP_LOCATION_DESCRIPTOR ThreadContext;
} MINIDUMP_THREAD;

typedef struct _MINIDUMP_THREAD_LIST {
  ULONG32         NumberOfThreads;
//  MINIDUMP_THREAD Threads[0];
} MINIDUMP_THREAD_LIST;

typedef enum _MINIDUMP_STREAM_TYPE { 
  UnusedStream               = 0,
  ReservedStream0            = 1,
  ReservedStream1            = 2,
  ThreadListStream           = 3,
  ModuleListStream           = 4,
  MemoryListStream           = 5,
  ExceptionStream            = 6,
  SystemInfoStream           = 7,
  ThreadExListStream         = 8,
  Memory64ListStream         = 9,
  CommentStreamA             = 10,
  CommentStreamW             = 11,
  HandleDataStream           = 12,
  FunctionTableStream        = 13,
  UnloadedModuleListStream   = 14,
  MiscInfoStream             = 15,
  MemoryInfoListStream       = 16,
  ThreadInfoListStream       = 17,
  HandleOperationListStream  = 18,
  LastReservedStream         = 0xffff
} MINIDUMP_STREAM_TYPE;

const char * stream_name(ULONG32 s)
{
	switch( s ) {
	case UnusedStream: return "UnusedStream";
	case ReservedStream0: return "ReservedStream0";
	case ReservedStream1: return "ReservedStream1";
	case ThreadListStream: return "ThreadListStream";
	case ModuleListStream: return "ModuleListStream";
	case MemoryListStream: return "MemoryListStream";
	case ExceptionStream:  return "ExceptionStream";
	case SystemInfoStream: return "SystemInfoStream";
	case ThreadExListStream: return "ThreadExListStream";
	case Memory64ListStream: return "Memory64ListStream";
	case CommentStreamA:     return "CommentStreamA";
	case CommentStreamW:     return "CommentStreamW";
	case HandleDataStream:   return "HandleDataStream";
	case FunctionTableStream: return "FunctionTableStream";
	case UnloadedModuleListStream: return "UnloadedModuleListStream";
	case MiscInfoStream: return "MiscInfoStream";
	case MemoryInfoListStream: return "MemoryInfoListStream";
	case ThreadInfoListStream: return "ThreadInfoListStream";
	case HandleOperationListStream: return "HandleOperationListStream";
	}
	
	if (s <= LastReservedStream)
		return "Unknown Reserved Stream";
	return "User-Defined stream";
}

void indent(FILE * out, int level)
{
	while (level-- > 0)
		fputc('\t', out);
}

void dump_text( int fd, RVA off, ULONG32 size, FILE * out, int level )
{
	char line[64];
	static const size_t buf_size = sizeof(line);
	ULONG32 pos;
	size_t  j;
	int   newline = 1;

	lseek( fd, off, SEEK_SET );
	
	for (pos = 0; pos != size; ) {
		size_t br = size - pos  < buf_size ? size - pos : buf_size;
		read( fd, line, br);
		for (j = 0; j < br; ++j) {
		
			if (line[j] == '\r')
				;
			else if (line[j] == '\n' || line[j] == 0) {
				putc('\n', out);
				newline = 1;
			}
			else {
				if (newline)
					indent(out, level);
				putc( line[j], out );
				newline = 0;
			}
		}
		pos += j;	
	}
	
	if (!newline)
		putc('\n', out);
}

void dump_binary( int fd, RVA off, ULONG32 size, FILE * out, int level )
{
	char line[32];
	static const size_t buf_size = sizeof(line);
	int n;
	ULONG32 pos;
	const char * pfx[2] = {"", " "};
	
	lseek( fd, off, SEEK_SET );
	
	for (pos = 0; pos != size; ) {
		size_t rb = size - pos < buf_size ? size - pos : buf_size;
		size_t j;
		
		n = read( fd, line, rb );
		assert (n == rb);
		
		indent(out, level);
		for (j = 0; j < rb; ++j)
			fprintf(out, "%s%02X", pfx[j != 0], line[j] & 0xffu);
		
		for (;j != buf_size; ++j)
			fprintf(out,"%s  ", pfx[j != 0]);
		
		fprintf(out,"    ");
		for (j = 0; j < rb; ++j)
			fprintf(out,"%c", isprint(line[j] & 0xff) ? line[j] : '.');
		
		fprintf(out,"\n");
		pos += rb;
	}
}

void dump_memory_list_stream( int fd, RVA off, ULONG32 size, FILE * out, int level )
{
	MINIDUMP_MEMORY_LIST       header;
	MINIDUMP_MEMORY_DESCRIPTOR item;
	static const size_t  header_size = sizeof(MINIDUMP_MEMORY_LIST);
	static const size_t  item_size   = sizeof(MINIDUMP_MEMORY_DESCRIPTOR);
	ULONG32              n;
	
	lseek( fd, off, SEEK_SET );
	read( fd, &header, header_size );
	off += header_size;
	
	indent(out, level);
	fprintf(out, "Streams: %" L32d "\n", header.NumberOfMemoryRanges );
	for (n = 0; n < header.NumberOfMemoryRanges; ++n) {
		lseek( fd, off + n * item_size, SEEK_SET );
		read( fd, &item, item_size );
		indent(out, level);
		fprintf(out, "MemoryStream #%" L32d ", @%" L64x ", size %" L32d "\n",
				n + 1, item.StartOfMemoryRange, item.Memory.DataSize );
		dump_binary( fd, item.Memory.Rva, item.Memory.DataSize, out, level + 1 );
	}
}

void dump_thread_list( int fd, RVA off, ULONG32 size, FILE * out, int level )
{
	MINIDUMP_THREAD_LIST       header;
	MINIDUMP_THREAD            item;
	static const size_t  header_size = sizeof(MINIDUMP_THREAD_LIST);
	static const size_t  item_size   = sizeof(MINIDUMP_THREAD);
	ULONG32              n;

	lseek( fd, off, SEEK_SET );
	read( fd, &header, header_size );
	off += header_size;

	indent(out, level);
	fprintf(out, "Threads: %" L32d "\n", header.NumberOfThreads );
	for (n = 0; n < header.NumberOfThreads; ++n) {
		lseek( fd, off + n * item_size, SEEK_SET );
		read( fd, &item, item_size );
		indent(out, level);
		fprintf(out, "Thread #%" L32d
				" ThreadId: %" L32d
				" SuspendCount: %" L32d
				" PriorityClass:%" L32d
				" Priority:%" L32d
				" Teb:%" L64x
				" Stack.StartOfMemoryRange:%" L64x
				"\n",
				n + 1,
				item.ThreadId, item.SuspendCount, item.PriorityClass,
				item.Priority, item.Teb,
				item.Stack.StartOfMemoryRange);

		indent(out, level + 1);
		fprintf( out, "ThreadContext\n" );
		dump_binary( fd, item.ThreadContext.Rva, item.ThreadContext.DataSize, out, level + 2 );

		indent(out, level + 1);
		fprintf( out, "Stack\n" );
		dump_binary( fd, item.Stack.Memory.Rva, item.Stack.Memory.DataSize, out, level + 2 );
	}
}

void dump_dir( int fd, RVA off, ULONG32 n, FILE * out, int level )
{
	MINIDUMP_DIRECTORY dir;
	ULONG32 j;
	
	for (j = 0; j < n; ++j) {
		lseek( fd, off + j * sizeof(dir), SEEK_SET );
		read( fd, &dir, sizeof(dir));
		
		indent( out, level );
		fprintf(out,"Stream %" L32d "\n", j + 1);
		fprintf(out,"  StreamType: %s(%" L32d ", 0x%" L32x ")\n", stream_name(dir.StreamType), dir.StreamType, dir.StreamType );
		fprintf(out,"  Location  : %" L32d " , size %" L32d "\n", dir.Location.Rva, dir.Location.DataSize );
		
		switch ( dir.StreamType ) {
		case MemoryListStream:
			dump_memory_list_stream(fd, dir.Location.Rva, dir.Location.DataSize, out, level + 1);
			break;

		case ThreadListStream:
			dump_thread_list(fd, dir.Location.Rva, dir.Location.DataSize, out, level + 1);
			break;
			
		case 0x47670003:
		case 0x47670004:
		case 0x47670006:
		case 0x47670007:
		case 0x47670009:
			dump_text( fd, dir.Location.Rva, dir.Location.DataSize, out, level + 1 );
			break;
		
		default:
			dump_binary( fd, dir.Location.Rva, dir.Location.DataSize, out, level + 1);
		}
		
	}
}

void dump_file(int fd, FILE * out)
{
	MINIDUMP_HEADER header;
	
	read( fd, &header, sizeof(header) );
	fprintf(out,"Signature         : %08" L32x "\n", header.Signature);
	fprintf(out,"Version           : %08" L32x "\n", header.Version);
	fprintf(out,"NumberOfStreams   : %"   L32u "\n", header.NumberOfStreams);
	fprintf(out,"StreamDirectoryRva: %"   L32u "\n", header.StreamDirectoryRva);
	fprintf(out,"CheckSum          : %08" L32x "\n", header.CheckSum);
	fprintf(out,"TimeDateStamp     : %"   L32u "\n", header.TimeDateStamp);
	fprintf(out,"Flags             : %08" L64x "\n", header.Flags);
	dump_dir( fd, header.StreamDirectoryRva, header.NumberOfStreams, out, 0 );
}

int main(int argc, char ** argv)
{
	int j;
	
	for (j = 1; j < argc; ++j) {
		int fd = open(argv[j], O_RDONLY | O_BINARY);
		if (fd == -1)
			perror( argv[j] );
		else {
			dump_file( fd, stdout );
			close(fd);
		}
	}
	return 0;
}
