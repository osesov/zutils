//
// $Id$
//
// Created by Oleg Sesov 19-Sep-2014
//
// Copyright (C) 2014 Zodiac Interactive, LLC
//

#ifndef __ZODIAC_DALSHARED_RMI_H__
#define __ZODIAC_DALSHARED_RMI_H__

#include "toopl/common/tkl_stdint.h"

namespace Zodiac { namespace RMI
{
#define ZODIAC_RMI_INTERFACE( name ) struct name : public Zodiac::RMI::Client
#define ZODIAC_RMI_METHOD2(name, proto, ...) \
	struct \
	{ \
		typedef Zodiac::RMI::Function<proto>::Type Type; \
		static const char * name() { return #name; } \
		static const Annotation& annotation() { Annotation ann(__VA_ARGS__); return &ann;} \
	} \
	static name(Zodiac::RMI::EntryInfo&, Zodiac::RMI::Function<proto>::Pointer); \
	\
	Zodiac::RMI::CallStatus name(Zodiac::RMI::Function<proto>::Arg1 a1, Zodiac::RMI::Function<proto>::Arg2 a2) \
	{ \
		return call_method( #name, a1, a2 ); \
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

	struct DVBS_RPC
	{
	};

	template <>
	struct RmiTransport<DVBS_RPC> : public IRmiTransport
	{

	};

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
		struct Address
		{

		};

		struct Annotate_1 {};
		struct Annotate_2 {};
		struct Annotate_3 {};
		struct Annotate_4 {};
	};

	struct JSON_RPC
	{

	};

	template <class T> void annotation(T);
	template <class A1, class A2> void annotation(A1, A2);
}}

#endif // __ZODIAC_DALSHARED_RMI_H__
