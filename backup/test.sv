

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

endclass

module test();

    RichMailbox rmbx;
    mailbox mbx;
    wire a = 0;
    wire b = 1;
    wire c = a & b;
    int n;

    initial begin
        rmbx = new(1);

        rmbx.put(1);
        $display("p1d");
        $display("full:%d",rmbx.full());
        rmbx.put(2);
        $display("p2d");
        rmbx.put(3);
        $display("p3d");

        rmbx.get(n);
        $display("g1d %d",n);

        rmbx.get(n);
        $display("g2d %d",n);

        rmbx.get(n);
        $display("g3d %d",n);

    end



endmodule 