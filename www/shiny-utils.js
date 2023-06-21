$(function() {
  // define variables for visNetwork customization
  var inAddNodeMode = false;
  var inAddEdgeMode = false;

  Shiny.addCustomMessageHandler("visShinyGrabNetwork", function(data) {
    // get container id
    var el = document.getElementById("graph"+data.id);
    var network = el.chart;
    console.log(network);
  });

  // edit_id default is "add_node_mode"
  Shiny.addCustomMessageHandler("visShinyAddNodeMode", function(data) {
    inAddNodeMode = false;
    // get container id
    var el = document.getElementById("graph"+data.id);
    var network = el.chart;
    console.log('Inside visShinyAddNodeMode: inAddNodeMode is' + inAddNodeMode);
    if (inAddNodeMode) {
      network.disableEditMode();
      inAddNodeMode = false;
      Shiny.setInputValue(data.edit_id, inAddNodeMode, {priority: 'event'});
    } else {
      network.addNodeMode();
      inAddNodeMode = true;
      Shiny.setInputValue(data.edit_id, inAddNodeMode, {priority: 'event'});
    }
  });

  // edit_id default is "add_edge_mode"
  Shiny.addCustomMessageHandler("visShinyAddEdgeMode", function(data) {
    inAddEdgeMode = false;
    // get container id
    var el = document.getElementById("graph"+data.id);
    var network = el.chart;
    console.log('Inside visShinyAddEdgeMode: inAddEdgeMode is' + inAddEdgeMode);
    if (inAddEdgeMode) {
      network.disableEditMode();
      inAddEdgeMode = false;
      Shiny.setInputValue(data.edit_id, inAddEdgeMode, {priority: 'event'});
    } else {
      network.addEdgeMode();
      inAddEdgeMode = true;
      Shiny.setInputValue(data.edit_id, inAddEdgeMode, {priority: 'event'});
    }
  });

  Shiny.addCustomMessageHandler("visShinyDeleteMode", function(data) {
    // get container id
    var el = document.getElementById("graph"+data.id);
    var network = el.chart;
    console.log('Inside visShinyDeleteMode');
    var obj = {cmd: 'deleteElements', nodes: data.nodes, edges: data.edges};
    network.deleteSelected();
  });

  Shiny.addCustomMessageHandler("visShinyCancelAddNodeMode", function(data) {
    // get container id
    var el = document.getElementById("graph"+data.id);
    var network = el.chart;
    console.log('Inside visShinyCancelEdit');
    network.disableEditMode();
    inAddNodeMode = false;
    Shiny.setInputValue(data.edit_id, inAddNodeMode, {priority: 'event'});
  });

  Shiny.addCustomMessageHandler("visShinyCancelAddEdgeMode", function(data) {
    // get container id
    var el = document.getElementById("graph"+data.id);
    var network = el.chart;
    console.log('Inside visShinyCancelEdit');
    network.disableEditMode();
    inAddEdgeMode = false;
    Shiny.setInputValue(data.edit_id, inAddEdgeMode, {priority: 'event'});
  });

  deleteFunction = function(data, callback) {
    console.log('Inside deleteFunction');
    callback(data);
    var obj = {cmd: 'deleteElements', nodes: data.nodes, edges: data.edges};
    Shiny.setInputValue('network_all_graphChange', obj);
  };
});
