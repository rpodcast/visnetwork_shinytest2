init_network_data <- function() {
  nodes_df <- tibble::tibble(
    label = c("node 1", "node 2"),
    node_label = c("node 1", "node 2"),
    node_id = c("node_1", "node_2"),
    id = c("node_1", "node_2"),
    weight = c(1, 0),
    title = c("Title here", "Title here"),
    shape = c("box", "box"),
    color.background = "#97C2FC",
    color.border = "#2B7CE9",
    color.highlight.background = "#97C2FC",
    color.highlight.border = "#2B7CE9",
    color.hover.background = "#97C2FC",
    color.hover.border = "#2B7CE9",
    x = c(0, 0),
    y = c(-150, 20)
  )
  
  edges_df <- tibble::tibble(
    from = c("node_1"),
    to = c("node_2"),
    id = "node_1-node_2",
    label = as.character(1),
    weight = c(1),
    arrows = "to",
    smooth = TRUE,
    color.color = "#000000",
    color.highlight = "#000000",
    color.hover = "#000000",
    font.background = "#ffffff"
  )
  
  list(nodes_df = nodes_df, edges_df = edges_df)
}

scheme_vis <- function(network_data, session = shiny::getDefaultReactiveDomain()) {
  scheme_visual <- visNetwork(network_data$nodes_df, network_data$edges_df) |>
    visInteraction(
      multiselect = TRUE,
      selectConnectedEdges = TRUE,
      hover = TRUE
    ) |>
    visEdges(
      arrows = "to",
      smooth = TRUE,
      font = list(background = "white"),
      color = list(color = "#000000")
    ) |>
    visNodes(label = TRUE, physics = FALSE)
  
  if (("x" %in% names(network_data$nodes_df)) & ("y" %in% names(network_data$edges_df))) {
    if (all(network_data$nodes_df$y >= 0)) {
      scheme_visual <- scheme_visual |>
        visIgraphLayout(layout = "layout_nicely", randomSeed = 123, type = "full")
    }
    scheme_visual <- scheme_visual |>
      visLayout(randomSeed = 7, improveLayout = TRUE)
  }
  
  if (!is.null(session)) {
    scheme_visual <- scheme_add_shiny(scheme_visual, session = session)
  }
}

scheme_add_shiny <- function(
    graph, 
    inputId = "network_all",
    addNodeId = "add_node_mode",
    addEdgeId = "add_edge_mode",
    dragId = "drag_object",
    session = shiny::getDefaultReactiveDomain()) {
  
  if (is.null(session)) stop("you must supply the Shiny session parameter", call. = FALSE)
  
  scheme_visual <- graph |>
    visNetwork::visEvents(
      dragEnd = glue::glue(
      "function(params) {
        Shiny.onInputChange('<<dragId>>', params);
      }",
      .open = "<<",
      .close = ">>"
      )
    ) |>
    visNetwork::visOptions(
      manipulation = list(
        enabled = FALSE,
        initiallyActive = FALSE,
        addNode = htmlwidgets::JS(
          glue::glue(
            "function(data, callback) {
               cmd = 'addNode';
               data.label = 'change me';
               data.node_label = 'change me';
               data.shape = 'box';
               var obj = {cmd: cmd, id : data.id, label : data.label, node_label : data.node_label};
               console.log('onAdd: cmd is ' + cmd + ' id is ' + data.id + ' label is ' + data.label);
               inAddNodeMode = false;
               Shiny.setInputValue('<<addNodeId>>', inAddNodeMode, {priority: 'event'});
               callback(data);
               Shiny.setInputValue('<<inputId>>_graphChange', obj);
             }",
            .open = "<<",
            .close = ">>"
          )
        ),
        addEdge = htmlwidgets::JS(
          glue::glue(
            "function(data, callback) {
               callback(data); // must be called first for data.id to populate (see visNetwork source code)
               cmd = 'addEdge';
               var obj = {cmd: cmd, id: data.id, from: data.from, to: data.to};
               console.log('onEdge: cmd is ' + cmd + ' id is ' + data.id + ' from is ' + data.from + ' to is ' + data.to);
               inAddEdgeMode = false;
               Shiny.setInputValue('<<addEdgeId>>', inAddEdgeMode, {priority: 'event'});
               Shiny.setInputValue('<<inputId>>_graphChange', obj);
            }",
            .open = "<<",
            .close = ">>"
          )
        ),
        deleteNode = htmlwidgets::JS(
          glue::glue(
            "function(data, callback) {
              callback(data);
              var obj = {cmd: 'deleteElements', nodes: data.nodes, edges: data.edges};
              Shiny.setInputValue('<<inputId>>_graphChange', obj);
            }",
            .open = "<<",
            .close = ">>"
          )
        ),
        deleteEdge = htmlwidgets::JS(
          glue::glue(
            "function(data, callback) {
              callback(data);
              var obj = {cmd: 'deleteElements', nodes: data.nodes, edges: data.edges};
              Shiny.setInputValue('<<inputId>>_graphChange', obj);
            }",
            .open = "<<",
            .close = ">>"
          )
        )
      )
    )
  
  return(scheme_visual)
}

visGrabNetwork <- function(graph) {
  if (!any(class(graph) %in% "visNetwork_Proxy")) {
    stop("Need visNetwork Proxy object!")
  }
  data <- list(
    id = graph$id
  )
  
  graph$session$sendCustomMessage("visShinyGrabNetwork", data)
  graph
}

visAddNodeMode <- function(graph, edit_id = "add_node_mode", session = shiny::getDefaultReactiveDomain()) {
  if (!any(class(graph) %in% "visNetwork_Proxy")) {
    stop("Need visNetwork Proxy object!")
  }
  data <- list(
    id = graph$id,
    edit_id = session$ns(edit_id)
  )
  
  graph$session$sendCustomMessage("visShinyAddNodeMode", data)
  graph
}

visAddEdgeMode <- function(graph, edit_id = "add_edge_mode", session = shiny::getDefaultReactiveDomain()) {
  if (!any(class(graph) %in% "visNetwork_Proxy")) {
    stop("Need visNetwork Proxy object!")
  }
  data <- list(
    id = graph$id,
    edit_id = session$ns(edit_id)
  )
  
  graph$session$sendCustomMessage("visShinyAddEdgeMode", data)
  graph
}

visDeleteMode <- function(graph) {
  if (!any(class(graph) %in% "visNetwork_Proxy")) {
    stop("Need visNetwork Proxy object!")
  }
  data <- list(
    id = graph$id
  )
  
  graph$session$sendCustomMessage("visShinyDeleteMode", data)
  graph
}

visCancelAddNodeMode <- function(graph, edit_id = "add_node_mode", session = shiny::getDefaultReactiveDomain()) {
  if (!any(class(graph) %in% "visNetwork_Proxy")) {
    stop("Need visNetwork Proxy object!")
  }
  data <- list(
    id = graph$id,
    edit_id = session$ns(edit_id)
  )
  
  graph$session$sendCustomMessage("visShinyCancelAddNodeMode", data)
  graph
}

visCancelAddEdgeMode <- function(graph, edit_id = "add_edge_mode", session = shiny::getDefaultReactiveDomain()) {
  if (!any(class(graph) %in% "visNetwork_Proxy")) {
    stop("Need visNetwork Proxy object!")
  }
  data <- list(
    id = graph$id,
    edit_id = session$ns(edit_id)
  )
  
  graph$session$sendCustomMessage("visShinyCancelAddEdgeMode", data)
  graph
}
