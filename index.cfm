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

    <cfinvoke component="EventService"
    method="retrieveEvents"
    returnvariable="allEvents">
  </cfinvoke>

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

                    <cfoutput query="allEvents">
                      <cfif #EVENT_DATE# eq "">
                        <div class="external-event" style="background-color: #COLOR#;" data-id="#ID#">
                          #NAME#
                          <button class="btn btn-sm float-right delete-event" data-id="#ID#">X</button>
                      </div>
                      </cfif>

                  </cfoutput>

                  <cfif allEvents.recordCount EQ 0>
                      <cfoutput>
                        <hr/>

                        No event found.

                        <hr/>

                      </cfoutput>
                  </cfif>
                    <div class="checkbox">
                      <!---<label for="drop-remove">
                        <input type="checkbox" id="drop-remove">
                        remove after drop
                      </label>--->
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
      var currColor = '#fff';  // Default color for new events
  
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
                location.reload();
              },
              error: function(xhr, status, error) {
                  alert("Error: " + error);
              }
          });
      });

      $(document).on('click', '.delete-event', function() {
        var eventId = $(this).data('id');
        var eventElement = $(this).closest('.external-event'); // Get the event element

        // AJAX request to delete the event
        $.ajax({
            url: 'EventService.cfc?method=deleteEvent',
            type: 'POST',
            data: {
                id: eventId
            },
            success: function(response) {
                // If successful, remove the event element from the list
                eventElement.remove();
            },
            error: function(xhr, status, error) {
                alert("Error: " + error);
            }
        });
    });

      /* initialize the calendar
     -----------------------------------------------------------------*/
    //Date for the calendar events (dummy data)
    var date = new Date()
    var d    = date.getDate(),
        m    = date.getMonth(),
        y    = date.getFullYear()

    var Calendar = FullCalendar.Calendar;
    var Draggable = FullCalendar.Draggable;

    var containerEl = document.getElementById('external-events');
    var checkbox = document.getElementById('drop-remove');
    var calendarEl = document.getElementById('calendar');

      // Initialize FullCalendar

      new Draggable(containerEl, {
      itemSelector: '.external-event',
      eventData: function(eventEl) {
        // Extract text without including the delete button's text (X)
        var title = $(eventEl).contents().filter(function() {
            return this.nodeType === 3;  // Only select the text node
        }).text().trim();

        return {
          title: title,
          backgroundColor: window.getComputedStyle( eventEl ,null).getPropertyValue('background-color'),
          borderColor: window.getComputedStyle( eventEl ,null).getPropertyValue('background-color'),
          textColor: window.getComputedStyle( eventEl ,null).getPropertyValue('color'),
        };
      }
    });
    <cfinvoke component="EventService"
    method="retrieveEvents"
    returnvariable="allEvents">
  </cfinvoke>
      var calendar = new Calendar(calendarEl, {
          headerToolbar: {
              left: 'prev,next today',
              center: 'title',
              right: 'dayGridMonth,timeGridWeek,timeGridDay'
          },
          themeSystem: 'bootstrap',
          editable: true,
          droppable: true, // Allows dragging from the external list
          events: [
        // Output events from the server
        <cfoutput query="allEvents">
            {
                id: "#ID#",
                title: "#NAME#",
                start: "#dateFormat(EVENT_DATE, 'yyyy-MM-dd')#", // Single event_date field
                backgroundColor: "#COLOR#",
                borderColor: "#COLOR#",
            },
        </cfoutput>
    ],
          drop: function(info) {
            var eventDate = info.dateStr; // Get the dropped date as a string (YYYY-MM-DD format)
            var eventId = info.draggedEl.getAttribute('data-id'); // Get the ID of the dragged event
            
            // AJAX request to update the event's date in the database
            $.ajax({
                url: 'EventService.cfc?method=updateEventDate',
                type: 'POST',
                data: {
                    id: eventId,
                    newDate: eventDate
                },
                success: function(response) {
                    console.log("Event updated successfully");
                },
                error: function(xhr, status, error) {
                    alert("Error: " + error);
                }
            });
            
            // Remove the event from the external events list if the checkbox is checked
                info.draggedEl.parentNode.removeChild(info.draggedEl);
            
        }
      });
  
      calendar.render();
  
      // Function to initialize the external events as draggable
      function ini_events(ele) { 
    ele.each(function() {
      var title = $(this).contents().filter(function() {
          return this.nodeType === 3;  // Get only the text node
        }).text().trim();

        // Make the event draggable using jQuery UI
        $(this).data('event', {
          title: title,  // Use only the event name text
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



      ini_events($('#external-events div.external-event'))

  });
  </script>
  
  
</body>
</html>
