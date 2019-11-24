`timescale 1ns/1ps

class RichMailbox extends mailbox;

    int depth;


    function new(int depth=0);
        super.new(depth);
        this.depth = depth;
    endfunction

    function bit full();
        full = (this.num() == depth)?1:0;
    endfunction

    function bit empty();
        empty = (this.num() == 0)?1:0;
    endfunction

endclass:RichMailbox