//===-- MachException.cpp ---------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include <errno.h>
#include <sys/types.h>
#include <sys/ptrace.h>

#include "lldb/Core/StreamString.h"
#include "lldb/Host/Host.h"
#include "StopInfoMachException.h"

#include "MachException.h"
#include "ProcessMacOSXLog.h"

using namespace lldb_private;

// Routine mach_exception_raise
extern "C"
kern_return_t catch_mach_exception_raise
(
    mach_port_t exception_port,
    mach_port_t thread,
    mach_port_t task,
    exception_type_t exception,
    mach_exception_data_t code,
    mach_msg_type_number_t codeCnt
);

extern "C"
kern_return_t catch_mach_exception_raise_state
(
    mach_port_t exception_port,
    exception_type_t exception,
    const mach_exception_data_t code,
    mach_msg_type_number_t codeCnt,
    int *flavor,
    const thread_state_t old_state,
    mach_msg_type_number_t old_stateCnt,
    thread_state_t new_state,
    mach_msg_type_number_t *new_stateCnt
);

// Routine mach_exception_raise_state_identity
extern "C"
kern_return_t catch_mach_exception_raise_state_identity
(
    mach_port_t exception_port,
    mach_port_t thread,
    mach_port_t task,
    exception_type_t exception,
    mach_exception_data_t code,
    mach_msg_type_number_t codeCnt,
    int *flavor,
    thread_state_t old_state,
    mach_msg_type_number_t old_stateCnt,
    thread_state_t new_state,
    mach_msg_type_number_t *new_stateCnt
);

extern "C" boolean_t mach_exc_server(
        mach_msg_header_t *InHeadP,
        mach_msg_header_t *OutHeadP);

// Any access to the g_message variable should be done by locking the
// g_message_mutex first, using the g_message variable, then unlocking
// the g_message_mutex. See MachException::Message::CatchExceptionRaise()
// for sample code.

static MachException::Data *g_message = NULL;
//static pthread_mutex_t g_message_mutex = PTHREAD_MUTEX_INITIALIZER;


extern "C"
kern_return_t
catch_mach_exception_raise_state
(
    mach_port_t                 exc_port,
    exception_type_t            exc_type,
    const mach_exception_data_t exc_data,
    mach_msg_type_number_t      exc_data_count,
    int *                       flavor,
    const thread_state_t        old_state,
    mach_msg_type_number_t      old_stateCnt,
    thread_state_t              new_state,
    mach_msg_type_number_t *    new_stateCnt
)
{
    Log *log = ProcessMacOSXLog::GetLogIfAllCategoriesSet(PD_LOG_EXCEPTIONS);
    if (log)
    {
        log->Printf("::%s ( exc_port = 0x%4.4x, exc_type = %d ( %s ), exc_data = " MACH_EXCEPTION_DATA_FMT_HEX ", exc_data_count = %d)",
            __FUNCTION__,
            exc_port,
            exc_type, MachException::Name(exc_type),
            exc_data,
            exc_data_count);
    }
    return KERN_FAILURE;
}

extern "C"
kern_return_t
catch_mach_exception_raise_state_identity
(
    mach_port_t             exc_port,
    mach_port_t             thread_port,
    mach_port_t             task_port,
    exception_type_t        exc_type,
    mach_exception_data_t   exc_data,
    mach_msg_type_number_t  exc_data_count,
    int *                   flavor,
    thread_state_t          old_state,
    mach_msg_type_number_t  old_stateCnt,
    thread_state_t          new_state,
    mach_msg_type_number_t *new_stateCnt
)
{
    kern_return_t kret;
    Log * log = ProcessMacOSXLog::GetLogIfAllCategoriesSet(PD_LOG_EXCEPTIONS);
    if (log)
    {
        log->Printf("::%s ( exc_port = 0x%4.4x, thd_port = 0x%4.4x, tsk_port = 0x%4.4x, exc_type = %d ( %s ), exc_data[%d] = { " MACH_EXCEPTION_DATA_FMT_HEX ",  " MACH_EXCEPTION_DATA_FMT_HEX " })",
            __FUNCTION__,
            exc_port,
            thread_port,
            task_port,
            exc_type, MachException::Name(exc_type),
            exc_data_count,
            exc_data_count > 0 ? exc_data[0] : 0xBADDBADD,
            exc_data_count > 1 ? exc_data[1] : 0xBADDBADD);
    }
    kret = mach_port_deallocate (mach_task_self (), task_port);
    kret = mach_port_deallocate (mach_task_self (), thread_port);

    return KERN_FAILURE;
}

extern "C"
kern_return_t
catch_mach_exception_raise
(
    mach_port_t             exc_port,
    mach_port_t             thread_port,
    mach_port_t             task_port,
    exception_type_t        exc_type,
    mach_exception_data_t   exc_data,
    mach_msg_type_number_t  exc_data_count)
{
    Log * log = ProcessMacOSXLog::GetLogIfAllCategoriesSet(PD_LOG_EXCEPTIONS);
    if (log)
    {
        log->Printf("::%s ( exc_port = 0x%4.4x, thd_port = 0x%4.4x, tsk_port = 0x%4.4x, exc_type = %d ( %s ), exc_data[%d] = { " MACH_EXCEPTION_DATA_FMT_HEX ",  " MACH_EXCEPTION_DATA_FMT_HEX " })",
            __FUNCTION__,
            exc_port,
            thread_port,
            task_port,
            exc_type, MachException::Name(exc_type),
            exc_data_count,
            exc_data_count > 0 ? exc_data[0] : 0xBADDBADD,
            exc_data_count > 1 ? exc_data[1] : 0xBADDBADD);
    }

    g_message->task_port = task_port;
    g_message->thread_port = thread_port;
    g_message->exc_type = exc_type;
    g_message->exc_data.resize(exc_data_count);
    ::memcpy (&g_message->exc_data[0], exc_data, g_message->exc_data.size() * sizeof (mach_exception_data_type_t));
    return KERN_SUCCESS;
}


void
MachException::Message::PutToLog(Log *log) const
{
    if (log)
    {
        log->Printf("  exc_msg { bits = 0x%8.8lx size = 0x%8.8lx remote-port = 0x%8.8lx local-port = 0x%8.8lx reserved = 0x%8.8lx id = 0x%8.8lx } ",
                exc_msg.hdr.msgh_bits,
                exc_msg.hdr.msgh_size,
                exc_msg.hdr.msgh_remote_port,
                exc_msg.hdr.msgh_local_port,
                exc_msg.hdr.msgh_reserved,
                exc_msg.hdr.msgh_id);

        log->Printf( "reply_msg { bits = 0x%8.8lx size = 0x%8.8lx remote-port = 0x%8.8lx local-port = 0x%8.8lx reserved = 0x%8.8lx id = 0x%8.8lx }",
                reply_msg.hdr.msgh_bits,
                reply_msg.hdr.msgh_size,
                reply_msg.hdr.msgh_remote_port,
                reply_msg.hdr.msgh_local_port,
                reply_msg.hdr.msgh_reserved,
                reply_msg.hdr.msgh_id);
        state.PutToLog(log);
    }
}

lldb::StopInfoSP
MachException::Data::GetStopInfo (lldb_private::Thread &thread) const
{
    
    const size_t exc_data_count = exc_data.size();
    return StopInfoMachException::CreateStopReasonWithMachException (thread, 
                                                                     exc_type,
                                                                     exc_data_count,
                                                                     exc_data_count >= 1 ? exc_data[0] : 0,
                                                                     exc_data_count >= 2 ? exc_data[1] : 0);
}


void
MachException::Data::DumpStopReason() const
{
    Log * log = ProcessMacOSXLog::GetLogIfAllCategoriesSet();
    if (log)
    {
        int signal = SoftSignal();
        if (signal > 0)
        {
            const char *signal_str = Host::GetSignalAsCString(signal);
            if (signal_str)
                log->Printf ("signal(%s)", signal_str);
            else
                log->Printf ("signal(%i)", signal);
            return;
        }
        log->Printf ("%s", Name(exc_type));
    }
}

kern_return_t
MachException::Message::Receive(mach_port_t port, mach_msg_option_t options, mach_msg_timeout_t timeout, mach_port_t notify_port)
{
    Error err;
    Log * log = ProcessMacOSXLog::GetLogIfAllCategoriesSet(PD_LOG_EXCEPTIONS);
    mach_msg_timeout_t mach_msg_timeout = options & MACH_RCV_TIMEOUT ? timeout : 0;
    if (log && ((options & MACH_RCV_TIMEOUT) == 0))
    {
        // Dump this log message if we have no timeout in case it never returns
        log->Printf ("::mach_msg ( msg->{bits = %#x, size = %u remote_port = %#x, local_port = %#x, reserved = 0x%x, id = 0x%x}, option = %#x, send_size = %u, rcv_size = %u, rcv_name = %#x, timeout = %u, notify = %#x)",
                exc_msg.hdr.msgh_bits,
                exc_msg.hdr.msgh_size,
                exc_msg.hdr.msgh_remote_port,
                exc_msg.hdr.msgh_local_port,
                exc_msg.hdr.msgh_reserved,
                exc_msg.hdr.msgh_id,
                options,
                0,
                sizeof (exc_msg.data),
                port,
                mach_msg_timeout,
                notify_port);
    }

    err = ::mach_msg (&exc_msg.hdr,
                      options,                  // options
                      0,                        // Send size
                      sizeof (exc_msg.data),    // Receive size
                      port,                     // exception port to watch for exception on
                      mach_msg_timeout,         // timeout in msec (obeyed only if MACH_RCV_TIMEOUT is ORed into the options parameter)
                      notify_port);

    // Dump any errors we get
    if (log && err.GetError() != MACH_RCV_TIMED_OUT)
    {
        log->Error("::mach_msg ( msg->{bits = %#x, size = %u remote_port = %#x, local_port = %#x, reserved = 0x%x, id = 0x%x}, option = %#x, send_size = %u, rcv_size = %u, rcv_name = %#x, timeout = %u, notify = %#x)",
            exc_msg.hdr.msgh_bits,
            exc_msg.hdr.msgh_size,
            exc_msg.hdr.msgh_remote_port,
            exc_msg.hdr.msgh_local_port,
            exc_msg.hdr.msgh_reserved,
            exc_msg.hdr.msgh_id,
            options,
            0,
            sizeof (exc_msg.data),
            port,
            mach_msg_timeout,
            notify_port);
    }
    return err.GetError();
}

bool
MachException::Message::CatchExceptionRaise()
{
    bool success = false;
    // locker will keep a mutex locked until it goes out of scope
//    Mutex::Locker locker(&g_message_mutex);
    //    log->Printf ("calling  mach_exc_server");
    g_message = &state;
    // The exc_server function is the MIG generated server handling function
    // to handle messages from the kernel relating to the occurrence of an
    // exception in a thread. Such messages are delivered to the exception port
    // set via thread_set_exception_ports or task_set_exception_ports. When an
    // exception occurs in a thread, the thread sends an exception message to
    // its exception port, blocking in the kernel waiting for the receipt of a
    // reply. The exc_server function performs all necessary argument handling
    // for this kernel message and calls catch_exception_raise,
    // catch_exception_raise_state or catch_exception_raise_state_identity,
    // which should handle the exception. If the called routine returns
    // KERN_SUCCESS, a reply message will be sent, allowing the thread to
    // continue from the point of the exception; otherwise, no reply message
    // is sent and the called routine must have dealt with the exception
    // thread directly.
    if (mach_exc_server (&exc_msg.hdr, &reply_msg.hdr))
    {
        success = true;
    }
    else
    {
        Log * log = ProcessMacOSXLog::GetLogIfAllCategoriesSet(PD_LOG_EXCEPTIONS);
        if (log)
            log->Printf ("mach_exc_server returned zero...");
    }
    g_message = NULL;
    return success;
}



kern_return_t
MachException::Message::Reply(task_t task, pid_t pid, int signal)
{
    // Reply to the exception...
    Error err;

    Log *log = ProcessMacOSXLog::GetLogIfAllCategoriesSet();
    if (log)
        log->Printf("MachException::Message::Reply (task = 0x%4.4x, pid = %i, signal = %i)", task, pid, signal);

    // If we had a soft signal, we need to update the thread first so it can
    // continue without signaling
    int soft_signal = state.SoftSignal();
    int state_pid = LLDB_INVALID_PROCESS_ID;
    if (task == state.task_port)
    {
        // This is our task, so we can update the signal to send to it
        state_pid = pid;
    }
    else
    {
        err = ::pid_for_task(state.task_port, &state_pid);
    }

    if (signal == LLDB_INVALID_SIGNAL_NUMBER)
        signal = 0;

    if (log)
        log->Printf("MachException::Message::Reply () updating thread signal to %i (original soft_signal = %i)", signal, soft_signal);

    if (state_pid != LLDB_INVALID_PROCESS_ID)
    {
        errno = 0;
        if (::ptrace (PT_THUPDATE, state_pid, (caddr_t)state.thread_port, signal) != 0)
        {
            if (soft_signal != LLDB_INVALID_SIGNAL_NUMBER)
            // We know we currently can't forward signals for threads that didn't stop in EXC_SOFT_SIGNAL...
            // So only report it as an error if we should have been able to do it.
                err.SetErrorToErrno();
            else
                 err.Clear();
        }
        else
            err.Clear();

        if (log && log->GetMask().IsSet(PD_LOG_EXCEPTIONS) || err.Fail())
            err.PutToLog(log, "::ptrace (request = PT_THUPDATE, pid = %i, tid = 0x%4.4x, signal = %i)", state_pid, state.thread_port, signal);
    }

    err = ::mach_msg (  &reply_msg.hdr,
                        MACH_SEND_MSG | MACH_SEND_INTERRUPT,
                        reply_msg.hdr.msgh_size,
                        0,
                        MACH_PORT_NULL,
                        MACH_MSG_TIMEOUT_NONE,
                        MACH_PORT_NULL);

    if (log)
        log->LogIf (PD_LOG_EXCEPTIONS, "::mach_msg ( msg->{bits = %#x, size = %u, remote_port = %#x, local_port = %#x, reserved = 0x%x, id = 0x%x}, option = %#x, send_size = %u, rcv_size = %u, rcv_name = %#x, timeout = %u, notify = %#x) = 0x%8.8x",
            reply_msg.hdr.msgh_bits,
            reply_msg.hdr.msgh_size,
            reply_msg.hdr.msgh_remote_port,
            reply_msg.hdr.msgh_local_port,
            reply_msg.hdr.msgh_reserved,
            reply_msg.hdr.msgh_id,
            MACH_SEND_MSG | MACH_SEND_INTERRUPT,
            reply_msg.hdr.msgh_size,
            0,
            MACH_PORT_NULL,
            MACH_MSG_TIMEOUT_NONE,
            MACH_PORT_NULL,
            err.GetError());


    if (err.Fail())
    {
        if (err.GetError() == MACH_SEND_INTERRUPTED)
        {
            err.PutToLog(log, "::mach_msg() - send interrupted");
        }
        else
        {
            if (state.task_port == task)
            {
                err.PutToLog(log, "::mach_msg() - failed (task)");
                abort ();
            }
            else
            {
                err.PutToLog(log, "::mach_msg() - failed (child of task)");
            }
        }
    }

    return err.GetError();
}


void
MachException::Data::PutToLog(Log *log) const
{
    if (log == NULL)
        return;

    const char *exc_type_name = MachException::Name(exc_type);

    log->Printf ("    state { task_port = 0x%4.4x, thread_port =  0x%4.4x, exc_type = %i (%s) ...", task_port, thread_port, exc_type, exc_type_name ? exc_type_name : "???");

    const size_t exc_data_count = exc_data.size();
    // Dump any special exception data contents
    int soft_signal = SoftSignal();
    if (soft_signal > 0)
    {
        const char *sig_str = Host::GetSignalAsCString(soft_signal);
        log->Printf ("            exc_data: EXC_SOFT_SIGNAL (%i (%s))", soft_signal, sig_str ? sig_str : "unknown signal");
    }
    else
    {
        // No special disassembly for this data, just dump the data
        size_t idx;
        for (idx = 0; idx < exc_data_count; ++idx)
        {
            log->Printf("            exc_data[%u]: " MACH_EXCEPTION_DATA_FMT_HEX, idx, exc_data[idx]);
        }
    }
}


MachException::PortInfo::PortInfo() :
    count(0)
{
    ::bzero (masks, sizeof(masks));
    ::bzero (ports, sizeof(ports));
    ::bzero (behaviors, sizeof(behaviors));
    ::bzero (flavors, sizeof(flavors));
}


kern_return_t
MachException::PortInfo::Save (task_t task)
{
    count = EXC_TYPES_COUNT;
    Log *log = ProcessMacOSXLog::GetLogIfAllCategoriesSet (PD_LOG_EXCEPTIONS);
    if (log)
        log->Printf ("MachException::PortInfo::Save (task = 0x%4.4x)", task);
    Error err;
    if (log)
        log->Printf("::task_get_exception_ports (task=0x%4.4x, mask=0x%x, maskCnt<=>%u, ports, behaviors, flavors)...", task, EXC_MASK_ALL, count);
    err = ::task_get_exception_ports (task, EXC_MASK_ALL, masks, &count, ports, behaviors, flavors);
    if (log || err.Fail())
        err.PutToLog(log, "::task_get_exception_ports (task=0x%4.4x, mask=0x%x, maskCnt<=>%u, ports, behaviors, flavors)", task, EXC_MASK_ALL, count);
    if (log)
    {
        mach_msg_type_number_t i;
        log->Printf("Index Mask     Port     Behavior Flavor", masks[i], ports[i], behaviors[i], flavors[i]);
        log->Printf("===== -------- -------- -------- --------");
        for (i=0; i<count; ++i)
            log->Printf("[%3u] %8.8x %8.8x %8.8x %8.8x", i, masks[i], ports[i], behaviors[i], flavors[i]);
    }
    if (err.Fail())
        count = 0;
    return err.GetError();
}

kern_return_t
MachException::PortInfo::Restore (task_t task)
{
    Log *log = ProcessMacOSXLog::GetLogIfAllCategoriesSet (PD_LOG_EXCEPTIONS);
    if (log && log->GetMask().IsSet(PD_LOG_VERBOSE))
        log->Printf("MachException::PortInfo::Restore (task = 0x%4.4x)", task);
    uint32_t i = 0;
    Error err;
    if (count > 0)
    {
        for (i = 0; i < count; i++)
        {
            err = ::task_set_exception_ports (task, masks[i], ports[i], behaviors[i], flavors[i]);
            if (log || err.Fail())
                err.PutToLog(log, "::task_set_exception_ports ( task = 0x%4.4x, exception_mask = 0x%8.8x, new_port = 0x%4.4x, behavior = 0x%8.8x, new_flavor = 0x%8.8x )", task, masks[i], ports[i], behaviors[i], flavors[i]);

            if (err.Fail())
                break;
        }
    }
    count = 0;
    return err.GetError();
}

const char *
MachException::Name(exception_type_t exc_type)
{
    switch (exc_type)
    {
    case EXC_BAD_ACCESS:        return "EXC_BAD_ACCESS";
    case EXC_BAD_INSTRUCTION:   return "EXC_BAD_INSTRUCTION";
    case EXC_ARITHMETIC:        return "EXC_ARITHMETIC";
    case EXC_EMULATION:         return "EXC_EMULATION";
    case EXC_SOFTWARE:          return "EXC_SOFTWARE";
    case EXC_BREAKPOINT:        return "EXC_BREAKPOINT";
    case EXC_SYSCALL:           return "EXC_SYSCALL";
    case EXC_MACH_SYSCALL:      return "EXC_MACH_SYSCALL";
    case EXC_RPC_ALERT:         return "EXC_RPC_ALERT";
#ifdef EXC_CRASH
    case EXC_CRASH:             return "EXC_CRASH";
#endif
    default:
        break;
    }
    return NULL;
}



