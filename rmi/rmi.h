//
// $Id$
//
// Created by Oleg Sesov 19-Sep-2014
//
// Copyright (C) 2014 Zodiac Interactive, LLC
//

#ifndef __ZODIAC_DALSHARED_RMI_H__
#define __ZODIAC_DALSHARED_RMI_H__

#define RMI_STANDALONE

#ifdef RMI_STANDALONE

#include <string>
typedef unsigned int   uint32_t;
typedef unsigned short uint16_t;

namespace Zodiac { namespace RMI
{
    typedef std::string rmi_string;
}}

#else
#include "toopl/common/tkl_stdint.h"
#include "toopl/stl/tkl_string.h"

namespace Zodiac { namespace RMI
{
    typedef Tackle::string rmi_string;
}}

#endif

///////////////////////////////////////////////////////////////////////
// small macro library
///////////////////////////////////////////////////////////////////////
#define CONCATENATE(arg1, arg2)   CONCATENATE1(arg1, arg2)
#define CONCATENATE1(arg1, arg2)  CONCATENATE2(arg1, arg2)
#define CONCATENATE2(arg1, arg2)  arg1##arg2

#define FOR_EACH_0(what, ...)
#define FOR_EACH_1(what, x, ...) what(x)
#define FOR_EACH_2(what, x, ...) what(x)VA_EXPAND(FOR_EACH_1(what, __VA_ARGS__))
#define FOR_EACH_3(what, x, ...) what(x)VA_EXPAND(FOR_EACH_2(what, __VA_ARGS__))
#define FOR_EACH_4(what, x, ...) what(x)VA_EXPAND(FOR_EACH_3(what, __VA_ARGS__))
#define FOR_EACH_5(what, x, ...) what(x)VA_EXPAND(FOR_EACH_4(what, __VA_ARGS__))
#define FOR_EACH_6(what, x, ...) what(x)VA_EXPAND(FOR_EACH_5(what, __VA_ARGS__))
#define FOR_EACH_7(what, x, ...) what(x)VA_EXPAND(FOR_EACH_6(what, __VA_ARGS__))
#define FOR_EACH_8(what, x, ...) what(x)VA_EXPAND(FOR_EACH_7(what, __VA_ARGS__))

#ifdef _MSC_VER
#define VA_EXPAND(x) x
#else
#define VA_EXPAND(...) __VA_ARGS__
#endif

#define VA_NUM_ARGS(...) VA_EXPAND(VA_NUM_ARGS_( __VA_ARGS__, 5, 4, 3, 2, 1, 0))
#define VA_NUM_ARGS_(_1,_2,_3,_4,_5,N,...) N

#define FOR_EACH_(N, what, ...) CONCATENATE(FOR_EACH_, N)(what, __VA_ARGS__)
#define FOR_EACH(what, ...)     FOR_EACH_(VA_NUM_ARGS(__VA_ARGS__), what, ##__VA_ARGS__)

///////////////////////////////////////////////////////////////////////


namespace Zodiac { namespace RMI
{

#define ZODIAC_RMI_ANNOTATE2(x) Annotate2::x;

#define ZODIAC_RMI_INTERFACE( name ) struct name : public Zodiac::RMI::Client
#define ZODIAC_RMI_METHOD2(method_name, proto, ...) \
    FOR_EACH(ZODIAC_RMI_ANNOTATE2, Empty, __VA_ARGS__)
	struct \
	{ \
		typedef Zodiac::RMI::Function<proto>::Type Type; \
		static const char * name() { return #method_name; } \
        static void annotation() { FOR_EACHz(ZODIAC_RMI_ANNOTATE2, Empty, __VA_ARGS__) ;} \
	} \
	static method_name(Zodiac::RMI::EntryInfo&, Zodiac::RMI::Function<proto>::Pointer); \
	\
	Zodiac::RMI::CallStatus method_name(Zodiac::RMI::Function<proto>::Arg1 a1, Zodiac::RMI::Function<proto>::Arg2 a2) \
	{ \
		return call_method( #method_name, a1, a2 ); \
	}

	template <typename T>
	struct Function;

	template <typename R, typename A1, typename A2>
	struct Function<R (A1,A2)>
	{
		typedef R Return;
		typedef A1 Arg1;
		typedef A2 Arg2;

		typedef R (Type)(A1,A2);
		typedef R (*Pointer)(A1,A2);

		template <typename O>
		struct BindClass
		{
			typedef R (O::*Member)(A1, A2);
		};
	};

	struct EntryInfo
	{
		const char * name;

	private:

		EntryInfo() {}

		template <class T, class Binder>
		friend class Server;
	};

	enum CallStatus
	{
		CallSuccess
	};

	struct Annotation
	{
		size_t        num_args;
		const char *  rmi_name;
		const char ** arg_names;
	};

	class Client
	{
	public:
		template <class Address>
		void connect(Address addr);
		void disconnect();

	protected:
		template <typename T> struct in;
		template <typename T> struct out;
		template <typename T> struct inout;

		CallStatus call_method(const char * name);

		template <typename A1, typename A2>
		CallStatus call_method(const char * name, A1, A2);
	};

	template <class T, class Binder>
	class Server
	{
	public:
		template <typename Address>
		bool listen(Address addr);

	protected:
		template <typename Proto, typename Desc>
		void bind_method(Desc (*method)(EntryInfo&, Proto*), typename Function<Proto>::BindClass<Binder>::Member)
		{

		}
	};

	struct IRmiTransport
	{
		virtual ~IRmiTransport() {}
	};

	template <typename Address> struct RmiTransport;

	struct TcpAddress
	{
		uint32_t ip;
		uint16_t port;

	public:
		static TcpAddress localhost(uint16_t port)
		{
			TcpAddress addr = {0, port};
			return addr;
		}
	};

	template <>
	struct RmiTransport<TcpAddress> : public IRmiTransport
	{

	};

    ///////////////////////////////////////////////////////////////////
    struct DVBS_RPC;

	template <>
	struct RmiTransport<DVBS_RPC> : public IRmiTransport
	{

	};

    namespace Annotate2
    {
    	struct DVBS_RPC
	    {
            DVBS_RPC(const char * ipc_name);
	    };
    }

    ///////////////////////////////////////////////////////////////////
	struct InProcess
	{

	};

	template <>
	struct RmiTransport<InProcess> : public IRmiTransport
	{

	};
	//

	//////////////////////////////////////////////////////////////////////////
	// JSON rpc
	//////////////////////////////////////////////////////////////////////////

	struct JsonRPC
	{
    };

    namespace Annotate2
    {
        struct JSON_RPC
        {
            JSON_RPC(const char * rmi_name, const char * a1, const char * a2);
        };
    }
}}

#endif // __ZODIAC_DALSHARED_RMI_H__
