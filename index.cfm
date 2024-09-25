<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Calendar</title>

  <!-- Google Font: Source Sans Pro -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="./plugins/fontawesome-free/css/all.min.css">
  <!-- fullCalendar -->
  <link rel="stylesheet" href="./plugins/fullcalendar/main.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="./dist/css/adminlte.min.css">

  <style>
    .content-wrapper {
      margin-left: 0 !important;
      padding: 20px !important;
    }

    .container-fluid {
      max-width: 100% !important;
      padding: 20px !important;
    }

    .header-banner {
        background-color: #5a4b41;
        color: white;
        padding: 30px 0;
        text-align: center;
        border-bottom: 4px solid #e2ceb5; /* Slight golden divider */
      }
      .header-banner h1 {
        margin: 0;
        font-size: 2.5rem;
        font-family: 'Arial', sans-serif;
        letter-spacing: 1.5px;
      }
      .header-banner p {
        font-size: 1.2rem;
        color: #e2ceb5;
      }

  </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">

  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <section class="content-header">
      <div class="header-banner">
        <h1>      
          Calendar
        </h1>
        <p>
          Manage your day !
        </p>
      </div>
    </section>
    <!-- Main content -->
    <section class="content">
      <div class="container-fluid">
        <div class="row">
          <div class="col-md-3">
            <div class="sticky-top mb-3">
              <div class="card">
                <div class="card-header">
                  <h4 class="card-title">Draggable Events</h4>
                </div>
                <div class="card-body">
                  <!-- the events -->
                  <div id="external-events">
                    <div class="checkbox">
                      <label for="drop-remove">
                        <input type="checkbox" id="drop-remove">
                        remove after drop
                      </label>
                    </div>
                  </div>
                </div>
                <!-- /.card-body -->
              </div>
              <!-- /.card -->
              <div class="card">
                <div class="card-header">
                  <h3 class="card-title">Create Event</h3>
                </div>
                <div class="card-body">
                  <div class="btn-group" style="width: 100%; margin-bottom: 10px;">
                    <ul class="fc-color-picker" id="color-chooser">
                      <li><a class="text-primary" href="#"><i class="fas fa-square"></i></a></li>
                      <li><a class="text-warning" href="#"><i class="fas fa-square"></i></a></li>
                      <li><a class="text-success" href="#"><i class="fas fa-square"></i></a></li>
                      <li><a class="text-danger" href="#"><i class="fas fa-square"></i></a></li>
                      <li><a class="text-muted" href="#"><i class="fas fa-square"></i></a></li>
                    </ul>
                  </div>
                  <!-- /btn-group -->
                  <div class="input-group">
                    <input id="new-event" type="text" class="form-control" placeholder="Event Title">

                    <div class="input-group-append">
                      <button id="add-new-event" type="button" class="btn btn-primary">Add</button>
                    </div>
                    <!-- /btn-group -->
                  </div>
                  <!-- /input-group -->
                </div>
              </div>
            </div>
          </div>
          <!-- /.col -->
          <div class="col-md-9">
            <div class="card card-primary">
              <div class="card-body p-0">
                <!-- THE CALENDAR -->
                <div id="calendar"></div>
              </div>
              <!-- /.card-body -->
            </div>
            <!-- /.card -->
          </div>
          <!-- /.col -->
        </div>
        <!-- /.row -->
      </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->

</div>
<!-- ./wrapper -->

<!-- jQuery -->
<script src="./plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap -->
<script src="./plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- jQuery UI -->
<script src="./plugins/jquery-ui/jquery-ui.min.js"></script>
<!-- AdminLTE App -->
<script src="./dist/js/adminlte.min.js"></script>
<!-- fullCalendar 2.2.5 -->
<script src="./plugins/moment/moment.min.js"></script>
<script src="./plugins/fullcalendar/main.js"></script>
<!-- Page specific script -->
<script>
  $(document).ready(function() {
  
      // Color picker and event creation
      var currColor = '#3c8dbc';  // Default color for new events
  
      // Color chooser button behavior
      $('#color-chooser > li > a').click(function(e) {
          e.preventDefault();
          currColor = $(this).css('color'); // Set current color from chooser
          $('#add-new-event').css({
              'background-color': currColor,
              'border-color': currColor
          });
      });
  
      // Add new event button click handler
      $('#add-new-event').click(function(e) {
          e.preventDefault();
          var eventName = $('#new-event').val();
          if (eventName.length == 0) {
              return; // Do nothing if no name is entered
          }

          // AJAX request to add the event with color
          $.ajax({
              url: 'EventService.cfc?method=addEvent',
              type: 'POST',
              data: {
                  name: eventName,
                  color: currColor  // Send selected color
              },
              success: function(response) {
                  // Parse the response to handle the returned struct
                  const parsedResponse = JSON.parse(response);

                  // Check if the event was added successfully
                  if (parsedResponse.eventId) {
                      // Add new event element to the external events list
                      var event = $('<div />')
                          .css({
                              'background-color': parsedResponse.color,
                              'border-color': parsedResponse.color,
                              'color': '#fff'
                          })
                          .addClass('external-event')
                          .text(parsedResponse.name) // Use the event name from the response
                          .attr('data-id', parsedResponse.eventId); // Use the returned event ID

                      // Add a delete button (X)
                      event.append('<span class="delete-event">X</span>');
                      $('#external-events').prepend(event);

                      // Reinitialize drag for the new event
                      ini_events(event);
                      $('#new-event').val(''); // Clear the input field
                  } else {
                      // Handle the case where the event was not added successfully
                      alert("Error: Unable to add event. Please try again.");
                  }
              },
              error: function(xhr, status, error) {
                  alert("Error: " + error);
              }
          });
      });

  
      // Initialize FullCalendar
      var calendarEl = document.getElementById('calendar');
      var calendar = new FullCalendar.Calendar(calendarEl, {
          headerToolbar: {
              left: 'prev,next today',
              center: 'title',
              right: 'dayGridMonth,timeGridWeek,timeGridDay'
          },
          editable: true,
          droppable: true, // Allows dragging from the external list
          events: function(fetchInfo, successCallback, failureCallback) {

          },
          eventClick: function(info) {

          }
      });
  
      calendar.render();
  
      // Function to initialize the external events as draggable
      function ini_events(ele) {
          ele.each(function() {
              // Create a jQuery UI draggable event
              $(this).data('event', {
                  title: $.trim($(this).text()),  // Use the element's text as the event title
                  id: $(this).attr('data-id'),  // Assign the event ID
                  backgroundColor: $(this).css('background-color'),  // Preserve color
                  borderColor: $(this).css('border-color'),  // Preserve border color
                  textColor: '#fff'  // Set text color
              });
  
              // Make the event draggable using jQuery UI
              $(this).draggable({
                  zIndex: 1070,
                  revert: true, // Will cause the event to revert back to its original position after drop
                  revertDuration: 0
              });
          });
      }
  });
  </script>
  
  
</body>
</html>
