import uvm_pkg::*;
`include "uvm_macros.svh"
`timescale 1ns/1ps

interface my_interface;
    logic clk,rst;
    logic [7:0] data_in_bus;
    logic data_valid_in;
    logic data_in_wire;
    logic par_enable;
    logic [7:0] prescale;
    logic par_type;

    logic data_out_wire;
    logic busy;
    logic [7:0] data_out_bus;
    logic data_valid_out;
endinterface

class tx_transaction extends uvm_sequence_item;

    rand logic rst;
    rand logic [7:0] data_in_bus;
    rand logic data_valid_in;
    rand logic data_in_wire;
    rand logic par_enable;
    rand logic [7:0] prescale;
    rand logic par_type;

    logic data_out_wire;
    logic busy;
    logic [7:0] data_out_bus;
    logic data_valid_out;

    function new(input string inst = "tx_transaction");
        super.new(inst);
    endfunction

    `uvm_object_utils_begin(tx_transaction)
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
        prescale inside {4,8};
    }

endclass

class rx_transaction extends uvm_sequence_item;

    rand logic rst;
    rand logic [7:0] data_in_bus;
    rand logic data_valid_in;
    rand logic data_in_wire;
    rand logic par_enable;
    rand logic [7:0] prescale;
    rand logic par_type;

    logic data_out_wire;
    logic busy;
    logic [7:0] data_out_bus;
    logic data_valid_out;

    function new(input string inst = "rx_transaction");
        super.new(inst);
    endfunction

    `uvm_object_utils_begin(rx_transaction)
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

endclass

class tx_seq extends uvm_sequence #(tx_transaction);

    `uvm_object_utils(tx_seq)

    tx_transaction tx_trans;

    function new (input string inst="tx_seq");
        super.new(inst);
    endfunction

    task body();
        tx_trans = tx_transaction::type_id::create("tx_trans");
        for(int i = 0;i<2;i++)begin
            `uvm_do(tx_trans);
        end
    endtask

endclass

class rx_seq extends uvm_sequence #(rx_transaction);

    `uvm_object_utils(rx_seq)

    tx_transaction rx_trans;

    function new (input string inst="rx_seq");
        super.new(inst);
    endfunction

    task body();
        rx_trans = tx_transaction::type_id::create("rx_trans");
        for(int i = 0;i<2;i++)begin
            `uvm_do(rx_trans);
        end
    endtask

endclass

class tx_driver extends uvm_driver #(tx_transaction);
    `uvm_component_utils(tx_driver)

    tx_transaction tx_trans;
    virtual my_interface tx_drv_intf;

    function new(input string inst="tx_driver",uvm_component comp);
        super.new(inst,comp);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tx_trans = tx_transaction::type_id::create("tx_trans");
        
        if(!uvm_config_db#(virtual my_intf)::get(this,"","my_intf", tx_drv_intf))
            `uvm_fatal("tx_driver", "Unable to access interface")
    endfunction

    task run_phase (uvm_phase phase);
        forever begin
            
        end
    endtask

endclass

class rx_driver extends uvm_driver;
    `uvm_component_utils(rx_driver)

    rx_transaction rx_trans;
    virtual my_interface rx_drv_intf;

    function new(input string inst="rx_driver",uvm_component comp);
        super.new(inst,comp);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rx_trans = rx_transaction::type_id::create("rx_trans");
        
        if(!uvm_config_db#(virtual my_intf)::get(this,"","my_intf", rx_drv_intf))
            `uvm_fatal("rx_driver", "Unable to access interface")
    endfunction

    task run_phase (uvm_phase phase);
        forever begin
            
        end
    endtask

endclass 

class tx_monitor extends uvm_monitor;
    `uvm_component_utils(tx_monitor)

    tx_transaction tx_trans;
    virtual my_interface tx_mon_intf;
    uvm_analysis_port #(tx_transaction) tx_mon_ap;

    function new(input string inst="tx_monitor",uvm_component comp);
        super.new(inst,comp);
        tx_mon_ap = new("tx_mon_ap",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tx_trans = tx_transaction::type_id::create("tx_trans");
        
        if(!uvm_config_db#(virtual my_intf)::get(this,"","my_intf", tx_mon_intf))
            `uvm_fatal("tx_monitor", "Unable to access interface")
    endfunction

    task run_phase (uvm_phase phase);
        forever begin
            
        end
    endtask

endclass

class rx_monitor extends uvm_monitor;
    `uvm_component_utils(rx_monitor)

    rx_transaction rx_trans;
    virtual my_interface rx_mon_intf;
    uvm_analysis_port #(rx_transaction) rx_mon_ap;

    function new(input string inst="rx_monitor",uvm_component comp);
        super.new(inst,comp);
        rx_mon_ap = new("rx_mon_ap",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rx_trans = rx_transaction::type_id::create("rx_trans");
        
        if(!uvm_config_db#(virtual my_intf)::get(this,"","my_intf", rx_mon_intf))
            `uvm_fatal("rx_monitor", "Unable to access interface")
    endfunction

    task run_phase (uvm_phase phase);
        forever begin
            
        end
    endtask

endclass

class agent extends uvm_agent;
    `uvm_component_utils(agent)
endclass


class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

endclass