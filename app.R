library(shiny)
library(shinyvalidate)
library(bslib)
library(igraph)
library(visNetwork)

ui <- page_sidebar(
  tags$script(src = "shiny-utils.js"),
  title = "visNetwork and Shiny",
  sidebar = sidebar(
    title = "Scheme Controls",
    actionLink(
      "add_node",
      "Add Node"
    ),
    br(),
    actionLink(
      "add_edge",
      "Add Edge"
    )
  ),
  tagList(
    "Network Diagram",
    conditionalPanel(
      condition = "output.add_node_mode",
      tags$b("Click in an empty space to place a new node"),
      actionButton(
        "cancel_add_node",
        "Cancel"
      )
    ),
    conditionalPanel(
      condition = "output.add_edge_mode",
      tags$b("Click on a node and drag the edge to another node to connect them"),
      actionButton(
        "cancel_add_edge",
        "Cancel:"
      )
    ),
    visNetworkOutput("network_all")
  )
)

server <- function(input, output, session) {
  network_object <- reactive({
    network_data <- init_network_data()
    scheme_vis(network_data, session = session)
  })
  
  output$network_all <- renderVisNetwork({
    req(network_object())
    network_object()
  })
  
  add_node_mode <- reactive({
    input$add_node_mode
  })
  
  output$add_node_mode <- reactive({
    add_node_mode()
  })
  
  add_edge_mode <- reactive({
    input$add_edge_mode
  })
  
  output$add_edge_mode <- reactive({
    add_edge_mode()
  })
  
  purrr::walk(c("add_node_mode", "add_edge_mode"), ~outputOptions(output, .x, suspendWhenHidden = FALSE))
  
  observeEvent(input$add_node, {
    visNetworkProxy("network_all") |>
      visAddNodeMode()
  })
  
  observeEvent(input$add_edge, {
    visNetworkProxy("network_all") |>
      visAddEdgeMode()
  })
}

shinyApp(ui, server)