# Assesment

## Given Use case
A customer has an entertainment company and wants to organise a concert and wants a page where people can reserve a ticket. A ticket has a price. Only a few tickets are available per concert.

If it is not busy, a user can go directly to the page where the user can buy the ticket. However, if it is busy then the user must be queued to reduce the load on the system. The user is then directed to a 'wait’ page and should automatically go from the queue to the page where the ticket can be bought if there is space.

A user who is on the page to order a ticket may only take a few minutes to complete an order. When this time is up, the user may no longer order a ticket. The user then has to make room for the next customer.

## Solution
- The first solution I would ask the customer to consider, is to go for an integration with for example Eventix. Eventix offers a reliable and scalable solution, and will probably save you time and costs compared to a custom build solution.
- If a custom build ticket service is required, it is important to handle a high load on the server. There are multiple third party solutions available, for example [from queue-it](https://queue-it.com/virtual-waiting-room/) 
- For this assesment, we assume the webserver can handle the expected traffic. Therefore, I've opted letting the queue be handled by Ruby on Rails. This repository is a rough implementation of how such a solution would look like (not production ready)

## Acceptance criteria
### Event organizer
- A customer should be able to create an event. A title, description, start and end datetime, capacity and price are required. An event cannot be created for a past date. In order to sell tickets, an event needs to have a ticket sale.
- Once created, a customer can only update the title or the description. Changing the times, capacity and price are out of scope of the MVP, since this would be a process instead of a simple data update. When changing these fields, we need to take into account the already ordered tickets, and the reservations that would be present during the update.
- Creating an event should be in an admin portal behind authentication. only the customer who created the events should be able to update these events.
- For the MVP, we just have 1 type of tickets. no seats, ranks or early-birds

### Ticket buyer
- A ticket buyer should see a list of upcoming events. For each event, they can order max of 6 tickets.
- If the number of requested tickets is available, the ticket buyer is redirected to a form where they can fill in their name, email, age and gender (the last 2 are for event sale analysis). All these fields are required
    - If the ticket buyer does not complete the order within 8 minutes, they are redirected to the tickets overview with a message that the reservation is expired.
    - If the number of requested tickets are not directly available, because they are currently reserved by other ticket buyers, the ticket buyer stays on the waiting page, until
    - They are the first buyer in the queue and there are enough tickets available. They will be redirected to a page to add his order details
    - They are the first buyer in the queue, but there are not enough unsold tickets. They will be redirected to the tickets overview with a message that the event is sold out.
    - The reservation number is unique to the session of the ticket buyer. a reservation could be unique based on the session, the cookie or the user. All have their pros and cons, which should be discussed with the stakeholder.

### Other
- It is vital that we never sell more tickets than the capacity of a given ticket sale.
- The ticket_price of an order is the ticket_price the moment an order was made. Changing the price on an event should not change the price of an order. It can change the price of a reservation
- The change in capacity of an event does not change the capacity of a ticket sale. This prepares us for the future when we want to have multiple rounds of ticket_sales
- If a payment is not completed within 10 minutes, the order should be cancelled, and the bought tickets should become available again in the ticket sale, and the user should receive an email (out of scope for the MVP)
- If a payment suceeded, the ticket buyer can download their tickets as pdf from the page, and they will receive their tickets by email (out of scope for MVP)

## Implementation
### Handling race conditions
By default, Rails does not lock records, which makes it prone to inconsistencies due to race conditions.
We solve this by locking the ticket sale when we process an order or a reservation. These locks should be as short as possible to prevent performance issues. Since we now have the guarantee that there are never two processes operating at the ticket sale at the same time, we are sure we never sell more tickets than we have in stock. it also prevents the situation where a event buyer orders a ticket which is expiring at the exact same time
- It is absolutely vital that all actions related to sellings tickets, are done through the TicketSale Service. The TicketSale is acting as our aggregate here, protecting the business rules for overselling, and making sure nothing changes while an operation is performed. One should never directly create reservations or orders without going through the service.

## Extendibility
- because we are strict in our dependency management, it would be easy to extend this system.
    - Orders and Events don't need to know anything about ticket sales, reservations, etc. These entities are prone to becoming
    god classes, so we want to be strict in the dependecies we add to these classes
    - All actions related to selling tickets are going through the ticket sale. 
    - Easy to extend to multiple ticket sales. For example for an early bird price and a regular price (price should be copied from )
    - Easy to extend the sort of ticket sale. for example for unseated tickets and seated tickets, depending on the event or the venue of the event

## Scalability
- Ticket sale queues are processed async with ActiveJob (using sidekiq). This is easy to scale by adding extra workers
- If the locking of the ticket sale becomes the bottle neck, one could create multiple ticket sales and randomly assign a reservation to the queue
- Updates about the reservation status are broadcasted back to the ticket buyer using Actioncable. ActionCable might become a bottle neck. [Any cable](https://nebulab.com/blog/actioncable-vs-anycable-fight) can be good be a alternative.

## Security
- We don't expose reservation ids because they are incremental and can be guessed. The only thing we expose is the reservation code
- The quantity of an order can not be tinkered with, since we read it from the reservation upon submitting an order.

### Event organizer portal
- Authenticated with devise (not implemented)

## Backlog
- Complete the flows for expiration and sold out in the frontend, removing the reservation number from the session
- Add devise for event organizer portal, and extract the creation of events to the event organizer portal
- Add system specs and implementation for non happy flows (the frontend is quite buggy at the moment)