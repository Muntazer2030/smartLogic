// Truth tables for basic logic gates

Map andGateTruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "AND Gate",
    "INPUTS": ["A", "B"],
    "OUTPUTS": ["Y1"],
    "DATA": [
      {"A": 0, "B": 0, "Y1": 0},
      {"A": 0, "B": 1, "Y1": 0},
      {"A": 1, "B": 0, "Y1": 0},
      {"A": 1, "B": 1, "Y1": 1},
    ],
  },
};

Map notGateTruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "NOT Gate",
    "INPUTS": ["A"],
    "OUTPUTS": ["Y1"],
    "DATA": [
      {"A": 0, "Y1": 1},
      {"A": 1, "Y1": 0},
    ],
  },
};

Map orGateTruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "OR Gate",
    "INPUTS": ["A", "B"],
    "OUTPUTS": ["Y1"],
    "DATA": [
      {"A": 0, "B": 0, "Y1": 0},
      {"A": 0, "B": 1, "Y1": 1},
      {"A": 1, "B": 0, "Y1": 1},
      {"A": 1, "B": 1, "Y1": 1},
    ],
  },
};

Map nandGateTruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "NAND Gate",
    "INPUTS": ["A", "B"],
    "OUTPUTS": ["Y1"],
    "DATA": [
      {"A": 0, "B": 0, "Y1": 1},
      {"A": 0, "B": 1, "Y1": 1},
      {"A": 1, "B": 0, "Y1": 1},
      {"A": 1, "B": 1, "Y1": 0},
    ],
  },
};

Map norGateTruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "NOR Gate",
    "INPUTS": ["A", "B"],
    "OUTPUTS": ["Y1"],
    "DATA": [
      {"A": 0, "B": 0, "Y1": 1},
      {"A": 0, "B": 1, "Y1": 0},
      {"A": 1, "B": 0, "Y1": 0},
      {"A": 1, "B": 1, "Y1": 0},
    ],
  },
};

Map xorGateTruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "XOR Gate",
    "INPUTS": ["A", "B"],
    "OUTPUTS": ["Y1"],
    "DATA": [
      {"A": 0, "B": 0, "Y1": 0},
      {"A": 0, "B": 1, "Y1": 1},
      {"A": 1, "B": 0, "Y1": 1},
      {"A": 1, "B": 1, "Y1": 0},
    ],
  },
};

Map xnorGateTruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "XNOR Gate",
    "INPUTS": ["A", "B"],
    "OUTPUTS": ["Y1"],
    "DATA": [
      {"A": 0, "B": 0, "Y1": 1},
      {"A": 0, "B": 1, "Y1": 0},
      {"A": 1, "B": 0, "Y1": 0},
      {"A": 1, "B": 1, "Y1": 1},
    ],
  },
};

// Truth tables for advanced logic gates

Map halfAdderTruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "Half Adder",
    "INPUTS": ["A", "B"],
    "OUTPUTS": ["Y1", "Y2"],
    "DATA": [
      {"A": 0, "B": 0, "Y1": 0, "Y2": 0},
      {"A": 0, "B": 1, "Y1": 1, "Y2": 0},
      {"A": 1, "B": 0, "Y1": 1, "Y2": 0},
      {"A": 1, "B": 1, "Y1": 0, "Y2": 1},
    ],
  },
};

Map fullAdderTruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "Full Adder",
    "INPUTS": ["A", "B", "C"],
    "OUTPUTS": ["Y1", "Y2"],
    "DATA": [
      {"A": 0, "B": 0, "C": 0, "Y1": 0, "Y2": 0},
      {"A": 0, "B": 0, "C": 1, "Y1": 1, "Y2": 0},
      {"A": 0, "B": 1, "C": 0, "Y1": 1, "Y2": 0},
      {"A": 0, "B": 1, "C": 1, "Y1": 0, "Y2": 1},
      {"A": 1, "B": 0, "C": 0, "Y1": 1, "Y2": 0},
      {"A": 1, "B": 0, "C": 1, "Y1": 0, "Y2": 1},
      {"A": 1, "B": 1, "C": 0, "Y1": 0, "Y2": 1},
      {"A": 1, "B": 1, "C": 1, "Y1": 1, "Y2": 1},
    ],
  },
};

Map halfSubtractorTruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "Half Subtractor",
    "INPUTS": ["A", "B"],
    "OUTPUTS": ["Y1", "Y2"],
    "DATA": [
      {"A": 0, "B": 0, "Y1": 0, "Y2": 0},
      {"A": 0, "B": 1, "Y1": 1, "Y2": 1},
      {"A": 1, "B": 0, "Y1": 1, "Y2": 0},
      {"A": 1, "B": 1, "Y1": 0, "Y2": 0},
    ],
  },
};

Map fullSubtractorTruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "Full Subtractor",
    "INPUTS": ["A", "B", "C"],
    "OUTPUTS": ["Y1", "Y2"],
    "DATA": [
      {"A": 0, "B": 0, "C": 0, "Y1": 0, "Y2": 0},
      {"A": 0, "B": 0, "C": 1, "Y1": 1, "Y2": 1},
      {"A": 0, "B": 1, "C": 0, "Y1": 1, "Y2": 1},
      {"A": 0, "B": 1, "C": 1, "Y1": 0, "Y2": 1},
      {"A": 1, "B": 0, "C": 0, "Y1": 1, "Y2": 0},
      {"A": 1, "B": 0, "C": 1, "Y1": 0, "Y2": 0},
      {"A": 1, "B": 1, "C": 0, "Y1": 0, "Y2": 0},
      {"A": 1, "B": 1, "C": 1, "Y1": 1, "Y2": 0},
    ],
  },
};

Map dFlipFlopTruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "D Flip-Flop",
    "INPUTS": ["A", "CLK"],
    "OUTPUTS": ["Y1", "Y2"],
    "DATA": [
      {"A": 0, "CLK": 0, "Y1": "No Change", "Y2": "No Change"},
      {"A": 0, "CLK": 1, "Y1": 0, "Y2": 1},
      {"A": 1, "CLK": 0, "Y1": "No Change", "Y2": "No Change"},
      {"A": 1, "CLK": 1, "Y1": 1, "Y2": 0},
    ],
  },
};

Map jkFlipFlopTruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "JK Flip-Flop",
    "INPUTS": ["A", "B", "CLK"],
    "OUTPUTS": ["Y1", "Y2"],
    "DATA": [
      {"A": 0, "B": 0, "CLK": 0, "Y1": "No Change", "Y2": "No Change"},
      {"A": 0, "B": 0, "CLK": 1, "Y1": "No Change", "Y2": "No Change"},
      {"A": 0, "B": 1, "CLK": 0, "Y1": "No Change", "Y2": "No Change"},
      {"A": 0, "B": 1, "CLK": 1, "Y1": 0, "Y2": 1},
      {"A": 1, "B": 0, "CLK": 0, "Y1": "No Change", "Y2": "No Change"},
      {"A": 1, "B": 0, "CLK": 1, "Y1": 1, "Y2": 0},
      {"A": 1, "B": 1, "CLK": 0, "Y1": "No Change", "Y2": "No Change"},
      {"A": 1, "B": 1, "CLK": 1, "Y1": "Toggle", "Y2": "Toggle"},
    ],
  },
};

Map tFlipFlopTruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "T Flip-Flop",
    "INPUTS": ["A", "CLK"],
    "OUTPUTS": ["Y1", "Y2"],
    "DATA": [
      {"A": 0, "CLK": 0, "Y1": "No Change", "Y2": "No Change"},
      {"A": 0, "CLK": 1, "Y1": "No Change", "Y2": "No Change"},
      {"A": 1, "CLK": 0, "Y1": "No Change", "Y2": "No Change"},
      {"A": 1, "CLK": 1, "Y1": "Toggle", "Y2": "Toggle"},
    ],
  },
};

Map decoder3To8TruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "3-to-8 Decoder",
    "INPUTS": ["A", "B", "C"],
    "OUTPUTS": ["Y0", "Y1", "Y2", "Y3", "Y4", "Y5", "Y6", "Y7"],
    "DATA": [
      {
        "A": 0,
        "B": 0,
        "C": 0,
        "Y0": 1,
        "Y1": 0,
        "Y2": 0,
        "Y3": 0,
        "Y4": 0,
        "Y5": 0,
        "Y6": 0,
        "Y7": 0,
      },
      {
        "A": 0,
        "B": 0,
        "C": 1,
        "Y0": 0,
        "Y1": 1,
        "Y2": 0,
        "Y3": 0,
        "Y4": 0,
        "Y5": 0,
        "Y6": 0,
        "Y7": 0,
      },
      {
        "A": 0,
        "B": 1,
        "C": 0,
        "Y0": 0,
        "Y1": 0,
        "Y2": 1,
        "Y3": 0,
        "Y4": 0,
        "Y5": 0,
        "Y6": 0,
        "Y7": 0,
      },
      {
        "A": 0,
        "B": 1,
        "C": 1,
        "Y0": 0,
        "Y1": 0,
        "Y2": 0,
        "Y3": 1,
        "Y4": 0,
        "Y5": 0,
        "Y6": 0,
        "Y7": 0,
      },
      {
        "A": 1,
        "B": 0,
        "C": 0,
        "Y0": 0,
        "Y1": 0,
        "Y2": 0,
        "Y3": 0,
        "Y4": 1,
        "Y5": 0,
        "Y6": 0,
        "Y7": 0,
      },
      {
        "A": 1,
        "B": 0,
        "C": 1,
        "Y0": 0,
        "Y1": 0,
        "Y2": 0,
        "Y3": 0,
        "Y4": 0,
        "Y5": 1,
        "Y6": 0,
        "Y7": 0,
      },
      {
        "A": 1,
        "B": 1,
        "C": 0,
        "Y0": 0,
        "Y1": 0,
        "Y2": 0,
        "Y3": 0,
        "Y4": 0,
        "Y5": 0,
        "Y6": 1,
        "Y7": 0,
      },
      {
        "A": 1,
        "B": 1,
        "C": 1,
        "Y0": 0,
        "Y1": 0,
        "Y2": 0,
        "Y3": 0,
        "Y4": 0,
        "Y5": 0,
        "Y6": 0,
        "Y7": 1,
      },
    ],
  },
};

Map encoder8To3TruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "8-to-3 Encoder",
    "INPUTS": ["A0", "A1", "A2", "A3", "A4", "A5", "A6", "A7"],
    "OUTPUTS": ["Y0", "Y1", "Y2"],
    "DATA": [
      {
        "A0": 1,
        "A1": 0,
        "A2": 0,
        "A3": 0,
        "A4": 0,
        "A5": 0,
        "A6": 0,
        "A7": 0,
        "Y0": 0,
        "Y1": 0,
        "Y2": 0,
      },
      {
        "A0": 0,
        "A1": 1,
        "A2": 0,
        "A3": 0,
        "A4": 0,
        "A5": 0,
        "A6": 0,
        "A7": 0,
        "Y0": 1,
        "Y1": 0,
        "Y2": 0,
      },
      {
        "A0": 0,
        "A1": 0,
        "A2": 1,
        "A3": 0,
        "A4": 0,
        "A5": 0,
        "A6": 0,
        "A7": 0,
        "Y0": 0,
        "Y1": 1,
        "Y2": 0,
      },
      {
        "A0": 0,
        "A1": 0,
        "A2": 0,
        "A3": 1,
        "A4": 0,
        "A5": 0,
        "A6": 0,
        "A7": 0,
        "Y0": 1,
        "Y1": 1,
        "Y2": 0,
      },
      {
        "A0": 0,
        "A1": 0,
        "A2": 0,
        "A3": 0,
        "A4": 1,
        "A5": 0,
        "A6": 0,
        "A7": 0,
        "Y0": 0,
        "Y1": 0,
        "Y2": 1,
      },
      {
        "A0": 0,
        "A1": 0,
        "A2": 0,
        "A3": 0,
        "A4": 0,
        "A5": 1,
        "A6": 0,
        "A7": 0,
        "Y0": 1,
        "Y1": 0,
        "Y2": 1,
      },
      {
        "A0": 0,
        "A1": 0,
        "A2": 0,
        "A3": 0,
        "A4": 0,
        "A5": 0,
        "A6": 1,
        "A7": 0,
        "Y0": 0,
        "Y1": 1,
        "Y2": 1,
      },
      {
        "A0": 0,
        "A1": 0,
        "A2": 0,
        "A3": 0,
        "A4": 0,
        "A5": 0,
        "A6": 0,
        "A7": 1,
        "Y0": 1,
        "Y1": 1,
        "Y2": 1,
      },
    ],
  },
};

Map multiplexer4To1TruthTable = {
  "command": "check_truth_table",
  "content": {
    "circuitName": "4-to-1 Multiplexer",
    "INPUTS": ["A0", "A1", "S0", "S1"],
    "OUTPUTS": ["Y1"],
    "DATA": [
      {"A0": 0, "A1": 0, "S0": 0, "S1": 0, "Y1": 0},
      {"A0": 0, "A1": 1, "S0": 0, "S1": 1, "Y1": 1},
      {"A0": 1, "A1": 0, "S0": 1, "S1": 0, "Y1": 0},
      {"A0": 1, "A1": 1, "S0": 1, "S1": 1, "Y1": 1},
    ],
  },
};



// Map of all available circuits for easy lookup in the dialog
final Map<String, Map> availableCircuits = {
  "And Gate": andGateTruthTable,
  "Or Gate": orGateTruthTable,
  "Not Gate": notGateTruthTable,
  "NAND Gate": nandGateTruthTable,
  "NOR Gate": norGateTruthTable,
  "XOR Gate": xorGateTruthTable,
  "XNOR Gate": xnorGateTruthTable,
  "Half Adder": halfAdderTruthTable,
  "Full Adder": fullAdderTruthTable,
  "Half Subtractor": halfSubtractorTruthTable,
  "Full Subtractor": fullSubtractorTruthTable,
  "D Flip-Flop": dFlipFlopTruthTable,
  "JK Flip-Flop": jkFlipFlopTruthTable,
  "T Flip-Flop": tFlipFlopTruthTable,
  "3-to-8 Decoder": decoder3To8TruthTable,
  "8-to-3 Encoder": encoder8To3TruthTable,
  "4-to-1 Multiplexer": multiplexer4To1TruthTable,
};







/*  this the message that will go to the mqtt broker to test the circuit on the borad using the esp

{
  "command":"check_truth_table",
  "content":{
    "circuitName": "2-to-4 Decoder Truth Table",
    "INPUTS": [
        "A",
        "B"
    ],
    "OUTPUTS": [
        "Z"
    ],
    "DATA": [
        {
            "A": 0,
            "B": 0,
            "Z": 1
           
        },
        {
            "A": 0,
            "B": 1,
            "Z": 1
           
        },
        {
            "A": 1,
            "B": 0,
            "Z": 0
           
        },
        {
            "A": 1,
            "B": 1,
            "Z": 0}
    ]
}
}





*/