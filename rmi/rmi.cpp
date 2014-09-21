#include "sources/ipc/rmi.h"
#include "toopl/stl/tkl_string.h"

//////////////////////////////////////////////////////////////////////////
// test
ZODIAC_RMI_INTERFACE( IDalServer )
{
	ZODIAC_RMI_METHOD2( echo, void (const Tackle::string&, Tackle::string&)
		, DVBS_RPC("IPC_ECHO")
		, JSON_RPC("echo", "request", "reply") );
	ZODIAC_RMI_METHOD2( echo, void (const Tackle::string&, int) );
};

class DalServerImpl : public Zodiac::RMI::Server< IDalServer, DalServerImpl >
{
public:

	DalServerImpl()
	{
		bind_method<void (const Tackle::string&, Tackle::string&)>( &IDalServer::echo, &DalServerImpl::echo );
		bind_method<void (const Tackle::string&, int)>( &IDalServer::echo, &DalServerImpl::echo );
	}

	void echo(const Tackle::string& a0, Tackle::string& a1) {}
	void echo(const Tackle::string& a0, int a1) {}
};


void initialize()
{
	DalServerImpl dal_server;
	IDalServer    dal_client;
	Tackle::string reply;

	dal_server.listen( Zodiac::RMI::TcpAddress::localhost(81) );
	dal_client.connect( Zodiac::RMI::TcpAddress::localhost(81) );

	dal_client.echo("asd", reply);
}
