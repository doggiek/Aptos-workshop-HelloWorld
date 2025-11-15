module hello_blockchain::message {
    use std::signer;
    use std::string;
    use aptos_framework::event;
    #[test_only]
    use std::debug;

    //:!:>resource
    struct MessageHolder has key {
        message: string::String,
    }
    //<:!:resource

    #[event]
    struct MessageChange has drop, store {
        account: address,
        from_message: string::String,
        to_message: string::String,
    }

    fun init_module(account: &signer) {
        move_to(account, MessageHolder {
            message: string::utf8(b"Hello, Blockchain"),
        });
    }

    #[view]
    public fun get_message(): string::String {
        MessageHolder[@hello_blockchain].message
    }

    public entry fun set_message(account: &signer, message: string::String){
        let account_addr = signer::address_of(account);
        let old_message = MessageHolder[@hello_blockchain].message;
        MessageHolder[@hello_blockchain].message = message;

        event::emit(MessageChange {
            account: account_addr,
            from_message: old_message,
            to_message: message,
        });
    }

    #[test(account = @hello_blockchain)]
    fun sender_can_set_message(account: &signer){
        let msg: string::String = string::utf8(b"Running test for sender_can_set_message...");
        debug::print(&msg);

        init_module(account);

        set_message(account, string::utf8(b"Hello, World"));

        assert!(
            get_message() == string::utf8(b"Hello, World")
        );
    }
}