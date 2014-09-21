#include "rmi.h"


#define PRN_STRUCT_OFFSETS_(structure, field) printf(STRINGIZE(structure)":"STRINGIZE(field)" - offset = %d\n", offsetof(structure, field));
#define PRN_STRUCT_OFFSETS(field) PRN_STRUCT_OFFSETS_(struct a, field)

/////////////////////////////////////////////////

#define action(x) do_##x
@FOR_EACH(action, 1, 2)@

VA_NUM_ARGS()
VA_NUM_ARGS(a)
VA_NUM_ARGS(a,b)
FOR_EACH_1(ZODIAC_RMI_ANNOTATE2, JSON_RPC("echo", "request", "reply"))

///////////////////////////////////////////////////////////////////////
namespace Zodiac { namespace DAL
{
//    int x = FOR_EACH_NARG_(1, 2, 3, 8, 7, 6, 5, 4, 3, 2, 1, 0);

    //////////////////////////////////////////////////////////////////////////
    // test
    ZODIAC_RMI_INTERFACE( IDalServer )
    {
        ZODIAC_RMI_METHOD2( echo, void (const RMI::rmi_string&, RMI::rmi_string&)
            , DVBS_RPC("IPC_ECHO")
            , JSON_RPC("echo", "request", "reply") );
        ZODIAC_RMI_METHOD2( echo, void (const RMI::rmi_string&, int) );
    };

    class DalServerImpl : public Zodiac::RMI::Server< IDalServer, DalServerImpl >
    {
    public:

        DalServerImpl()
        {
            bind_method<void (const rmi_string&, rmi_string&)>( &IDalServer::echo, &DalServerImpl::echo );
            bind_method<void (const rmi_string&, int)>( &IDalServer::echo, &DalServerImpl::echo );
        }

        void echo(const rmi_string& a0, rmi_string& a1) {}
        void echo(const rmi_string& a0, int a1) {}
    };


    void initialize()
    {
        DalServerImpl dal_server;
        IDalServer    dal_client;
        rmi_string reply;

        dal_server.listen( Zodiac::RMI::TcpAddress::localhost(81) );
        dal_client.connect( Zodiac::RMI::TcpAddress::localhost(81) );

        dal_client.echo("asd", reply);
    }
}