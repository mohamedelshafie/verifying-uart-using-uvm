import uvm_pkg::*;
`include "uvm_macros.svh"
`timescale 1ns/1ns

interface my_interface;
    bit clk,rst;
    bit [7:0] data_in_bus;
    bit data_valid_in;
    bit data_in_wire;
    bit par_enable;
    bit [7:0] prescale;
    bit par_type;

    bit data_out_wire;
    bit busy;
    bit [7:0] data_out_bus;
    bit data_valid_out;
endinterface

class transaction extends uvm_sequence_item;

    rand bit rst;
    rand bit [7:0] data_in_bus;
    rand bit data_valid_in;
    rand bit data_in_wire;
    rand bit par_enable;
    rand bit [7:0] prescale;
    rand bit par_type;

    bit data_out_wire;
    bit busy;
    bit [7:0] data_out_bus;
    bit data_valid_out;

    function new(input string inst = "transaction");
        super.new(inst);
    endfunction

    `uvm_object_utils_begin(transaction)
    `uvm_field_int(data_in_bus,UVM_DEC)
    `uvm_field_int(rst,UVM_DEC)
    `uvm_field_int(data_valid_in,UVM_DEC)
    `uvm_field_int(data_in_wire,UVM_DEC)
    `uvm_field_int(par_enable,UVM_DEC)
    `uvm_field_int(prescale,UVM_DEC)
    `uvm_field_int(par_type,UVM_DEC)
    `uvm_field_int(data_out_wire,UVM_DEC)
    `uvm_field_int(busy,UVM_DEC)
    `uvm_field_int(data_out_bus,UVM_DEC)
    `uvm_field_int(data_valid_out,UVM_DEC)
    `uvm_object_utils_end

    constraint prescale_range{
        prescale inside {4,8,16};
    }
    constraint rst_weight{
        rst dist {1 := 9, 0 := 1};
    }

endclass

class tx_seq extends uvm_sequence #(transaction);

    `uvm_object_utils(tx_seq)

    transaction tx_trans;

    function new (input string inst="tx_seq");
        super.new(inst);
    endfunction

    task body();
        tx_trans = transaction::type_id::create("tx_trans");
        for(int i = 0;i<5;i++)begin
            `uvm_do(tx_trans);
        end
    endtask

endclass

class rx_seq extends uvm_sequence #(transaction);

    `uvm_object_utils(rx_seq)

    transaction rx_trans;

    function new (input string inst="rx_seq");
        super.new(inst);
    endfunction

    task body();
        rx_trans = transaction::type_id::create("rx_trans");
        for(int i = 0;i<1;i++)begin
            `uvm_do(rx_trans);
        end
    endtask

endclass

class seqr extends uvm_sequencer #(transaction);
    `uvm_component_utils(seqr)

    function new(string inst="seqr", uvm_component parent);
        super.new(inst,parent);
    endfunction
endclass

class virtual_seqr extends uvm_sequencer #(transaction);
    `uvm_component_utils(virtual_seqr)

    seqr tx_seqr1;
    seqr rx_seqr1;

    function new(string name = "virtual_seqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass

class virtual_seq extends uvm_sequence #(transaction);
    `uvm_object_utils(virtual_seq)
    `uvm_declare_p_sequencer(virtual_seqr)

    tx_seq tx_seq1;
    rx_seq rx_seq1;

    seqr tx_seqr1;
    seqr rx_seqr1;

    function new (string name = "virtual_seq");
        super.new(name);
    endfunction

    task body();
        tx_seq1 = tx_seq::type_id::create("tx_seq1");
        rx_seq1 = rx_seq::type_id::create("rx_seq1");

        fork
            tx_seq1.start(p_sequencer.tx_seqr1);
            rx_seq1.start(p_sequencer.rx_seqr1);
        join
    endtask
endclass

class tx_driver extends uvm_driver #(transaction);
    `uvm_component_utils(tx_driver)

    transaction tx_trans;
    virtual my_interface tx_drv_intf;

    function new(input string inst="tx_driver",uvm_component comp);
        super.new(inst,comp);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tx_trans = transaction::type_id::create("tx_trans");
        
        if(!uvm_config_db#(virtual my_interface)::get(this,"","my_intf", tx_drv_intf))
            `uvm_fatal("tx_driver", "Unable to access interface")
    endfunction

    virtual task run_phase (uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(tx_trans);
            tx_trans.print();
            tx_drv_intf.rst = tx_trans.rst;
            tx_drv_intf.data_in_bus = tx_trans.data_in_bus;
            tx_drv_intf.data_valid_in = tx_trans.data_valid_in;
            tx_drv_intf.par_enable = tx_trans.par_enable;
            tx_drv_intf.par_type = tx_trans.par_type;
            seq_item_port.item_done();
            //@(negedge top.dut.tx_clk); //or delay
            #1000000; //wait for the frame to finish
        end
    endtask

endclass

class rx_driver extends tx_driver;
    `uvm_component_utils(rx_driver)

    transaction rx_trans;
    virtual my_interface rx_drv_intf;

    function new(input string inst="rx_driver",uvm_component comp);
        super.new(inst,comp);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rx_trans = transaction::type_id::create("rx_trans");
        
        if(!uvm_config_db#(virtual my_interface)::get(this,"","my_intf", rx_drv_intf))
            `uvm_fatal("rx_driver", "Unable to access interface")
    endfunction

    task run_phase (uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(rx_trans);
            rx_drv_intf.rst = rx_trans.rst;
            //for loop at each negedge for the array of data in wire
            rx_drv_intf.data_in_wire = rx_trans.data_in_wire;
            rx_drv_intf.prescale = rx_trans.prescale;
            rx_drv_intf.par_enable = rx_trans.par_enable;
            rx_drv_intf.par_type = rx_trans.par_type;
            seq_item_port.item_done();
            @(negedge top.dut.rx_clk);
            @(negedge top.dut.tx_clk);
        end
    endtask

endclass 

class tx_monitor extends uvm_monitor;
    `uvm_component_utils(tx_monitor)
    //`uvm_analysis_imp_decl(_tx)

    transaction tx_trans;
    virtual my_interface tx_mon_intf;
    uvm_analysis_port #(transaction) tx_mon_ap;

    bit [7:0] packed_data;
    int ii=0;

    function new(input string inst="tx_monitor",uvm_component comp);
        super.new(inst,comp);
        tx_mon_ap = new("tx_mon_ap",this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tx_trans = transaction::type_id::create("tx_trans");
        
        if(!uvm_config_db#(virtual my_interface)::get(this,"","my_intf", tx_mon_intf))
            `uvm_fatal("tx_monitor", "Unable to access interface")
    endfunction

    virtual task run_phase (uvm_phase phase);
        forever begin
            //@(posedge tx_mon_intf.clk)
            #100000;
            tx_trans.rst = tx_mon_intf.rst;
            tx_trans.data_in_bus = tx_mon_intf.data_in_bus;
            tx_trans.data_valid_in = tx_mon_intf.data_valid_in;
            tx_trans.par_enable = tx_mon_intf.par_enable;
            tx_trans.par_type = tx_mon_intf.par_type;
            tx_trans.data_out_wire = tx_mon_intf.data_out_wire;
            tx_trans.busy = tx_mon_intf.busy;
            tx_trans.print();
            //if(tx_mon_intf.busy)begin
                tx_mon_ap.write(tx_trans);
                ii++;
            //end
            ii=0;
            //use tx_write function
        end
    endtask

endclass

class rx_monitor extends tx_monitor;
    `uvm_component_utils(rx_monitor)
    //`uvm_analysis_imp_decl(_rx)

    transaction rx_trans;
    virtual my_interface rx_mon_intf;
    uvm_analysis_port #(transaction) rx_mon_ap;

    function new(input string inst="rx_monitor",uvm_component comp);
        super.new(inst,comp);
        rx_mon_ap = new("rx_mon_ap",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rx_trans = transaction::type_id::create("rx_trans");
        
        if(!uvm_config_db#(virtual my_interface)::get(this,"","my_intf", rx_mon_intf))
            `uvm_fatal("rx_monitor", "Unable to access interface")
    endfunction

    /*task run_phase (uvm_phase phase);
        forever begin
            //use rx_write function
        end
    endtask*/

endclass

class agent extends uvm_agent;
    `uvm_component_utils(agent)

    tx_driver tx_drv;
    //rx_driver rx_drv;

    tx_monitor tx_mon;
    //rx_monitor rx_mon;

    seqr seqr1;
    //seqr seqr1;

    //uvm_analysis_port #(transaction) agt_ap; //transaction

    function new(input string inst="agent",uvm_component comp);
        super.new(inst,comp);
        //agt_ap = new("agt_ap",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tx_drv = tx_driver::type_id::create("tx_drv1",this);
        tx_mon = tx_monitor::type_id::create("tx_mon1",this);
        seqr1 = seqr::type_id::create("seqr1",this);

    endfunction

    function void connect_phase(uvm_phase phase);
        //connect drv & seqr
        tx_drv.seq_item_port.connect(seqr1.seq_item_export);
        //connect monitor ap to agent ap
        //tx_mon.tx_mon_ap.connect(agt_ap);
    endfunction

endclass

class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)
    `uvm_analysis_imp_decl(_tx)
    `uvm_analysis_imp_decl(_rx)
    
    uvm_analysis_imp_tx #(transaction, scoreboard) tx_sco_ap_tx; //transaction
    uvm_analysis_imp_rx #(transaction, scoreboard) rx_sco_ap_rx;
    transaction tx_trans[$];
    transaction rx_trans[$];

    transaction tx_trans_item,rx_trans_item;

    function new(string name="scoreboard",uvm_component comp);
        super.new(name,comp);
        tx_sco_ap_tx = new("tx_sco_ap_tx", this);
        rx_sco_ap_rx = new("rx_sco_ap_rx", this);
    endfunction

    //2 write functions:
    virtual function void write_tx(transaction recv);
        tx_trans.push_back(recv);
        //`uvm_info(get_type_name, "inside tx write function",UVM_NONE)
    endfunction

    virtual function void write_rx(transaction recv);
        rx_trans.push_back(recv);
        //`uvm_info(get_type_name, "inside rx write function",UVM_NONE)
    endfunction

    task tx_sco(); //chech start bit, parity bit, stop bit, and data.
        int count=0;
        bit [7:0] data_check;
        bit [10:0] packed_data_par;
        bit [9:0] packed_data_no_par;
        forever begin
            wait(tx_trans.size>0);
            if(tx_trans.size>0)begin
                tx_trans_item = tx_trans.pop_front();
                if(!tx_trans_item.rst)begin
                    if(tx_trans_item.data_out_wire)begin
                        `uvm_info(get_type_name,"Result is as Expected for rst case",UVM_NONE)
                    end
                    else begin
                        `uvm_info(get_type_name,"Error, in rst!",UVM_NONE)
                    end
                end
                else if(tx_trans_item.data_valid_in)begin
                    data_check = tx_trans_item.data_in_bus;
                end
                
                if(tx_trans_item.busy)begin
                    if(tx_trans_item.par_enable)begin
                        if(count <11)begin
                            packed_data_par[count] = tx_trans_item.data_out_wire;
                            count++;
                        end
                        else begin
                            count = 0;
                            if(data_check == packed_data_par[8:1])begin
                                `uvm_info(get_type_name,"Result is as Expected for data with parity case",UVM_NONE)
                            end
                            else begin
                                `uvm_info(get_type_name,"Error, in data with parity!",UVM_NONE)
                            end
                        end
                    end
                    else begin
                       if(count <10)begin
                            packed_data_no_par[count] = tx_trans_item.data_out_wire;
                            count++;
                        end
                        else begin
                            count = 0;
                            if(data_check == packed_data_no_par[8:1])begin
                                `uvm_info(get_type_name,"Result is as Expected for data without parity case",UVM_NONE)
                            end
                            else begin
                                `uvm_info(get_type_name,"Error, in data without parity!",UVM_NONE)
                            end
                        end
                    end
                end
            end
        end
    endtask

    task rx_sco();
        forever begin
            wait(rx_trans.size>0);
            if(rx_trans.size>0)begin
                rx_trans_item = rx_trans.pop_front();
                /*if(!rx_trans_item.rst)begin
                    pass
                end*/

            end
        end
    endtask

    task run_phase(uvm_phase phase);
        //reference model
        fork
            tx_sco();
            rx_sco();
        join
    endtask


endclass

class environment extends uvm_env;
    `uvm_component_utils(environment)

    transaction tx_trans;
    transaction rx_trans;

    agent tx_agent1,rx_agent1;

    scoreboard sco1;

    virtual_seqr virtual_seqr1;

    function new(string name="environment",uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        //uvm_factory factory = uvm_factory::get(); //for printing the factory
        super.build_phase(phase);
        virtual_seqr1 = virtual_seqr::type_id::create("virtual_seqr1",this);
        tx_agent1 = agent::type_id::create("tx_agent1",this);
        sco1 = scoreboard::type_id::create("sco1",this);
        rx_agent1 = agent::type_id::create("rx_agent1",this);

        set_inst_override_by_type("rx_agent1.*",tx_driver::get_type(),rx_driver::get_type());
        set_inst_override_by_type("rx_agent1.*",tx_monitor::get_type(),rx_monitor::get_type());
        //set_inst_override_by_type("rx_agent1.*",seqr::get_type(),seqr::get_type()); //no need

        
    endfunction

    function void connect_phase(uvm_phase phase);
        virtual_seqr1.tx_seqr1 = tx_agent1.seqr1;
        virtual_seqr1.rx_seqr1 = rx_agent1.seqr1;

        //connect scoreboard with two agents
        //tx_agent1.agt_ap.connect(sco1.tx_sco_ap);
        //rx_agent1.agt_ap.connect(sco1.rx_sco_ap);

        //connect scoreboard with two monitors
        tx_agent1.tx_mon.tx_mon_ap.connect(sco1.tx_sco_ap_tx);
    endfunction
endclass

class test1 extends uvm_test;
    `uvm_component_utils(test1)

    environment env1;
    virtual_seq virtual_seq1;

    function new(string name="test1",uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        virtual_seq1 = virtual_seq::type_id::create("virtual_seq1");
        env1 = environment::type_id::create("env1",this);
    endfunction
        
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        virtual_seq1.start(env1.virtual_seqr1);
        #6000;
        `uvm_info("test1","before dropping objection",UVM_NONE)
        phase.drop_objection(this);
    endtask
endclass

module top();

    test1 t1;
    my_interface intf_inst();

    UART_TOP dut(
        .clk(intf_inst.clk),
        .rst(intf_inst.rst),
        .data_in_bus(intf_inst.data_in_bus),
        .data_valid_in(intf_inst.data_valid_in),
        .data_in_wire(intf_inst.data_in_wire),
        .par_enable(intf_inst.par_enable),
        .prescale(intf_inst.prescale),
        .par_type(intf_inst.par_type),

        .data_out_wire(intf_inst.data_out_wire),
        .busy(intf_inst.busy),
        .data_out_bus(intf_inst.data_out_bus),
        .data_valid_out(intf_inst.data_valid_out)
    );

    initial begin
        intf_inst.clk = 1'b0;
        /*intf_inst.rst = 1'b0;
        #10
        intf_inst.rst = 1'b1;*/
    end

    always #5 intf_inst.clk = ~intf_inst.clk;

    initial begin
        $dumpvars;
        t1 = new("t1", null);
        uvm_config_db #(virtual my_interface)::set(null, "*", "my_intf", intf_inst);
        run_test();
        //#500;
    end
endmodule