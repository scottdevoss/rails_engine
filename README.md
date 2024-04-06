# Rails Engine Overview
Rails Engine is an E-Commerce application that uses CRUD functionality and Serive-Oriented Architecture to expose API endpoints for the frontend to consume. 

  - [Rails Engine Backend](https://github.com/scottdevoss/rails_engine) 

# Getting Started with Rails Engine

To begin your Rails Engine, you'll need the following prerequisites:
- Ruby Version x.x.x
- A terminal application, such as Terminal (MacOS) or [Windows Terminal](https://learn.microsoft.com/en-us/windows/terminal/) (Windows)
- A code editor, such as [VSCode](https://code.visualstudio.com/)

Once you've installed these prerequisites, you can begin installing Rails Engine.

## Step One: Install the Rails Engine Backend 

1. Clone down the [Rails Engine backend.](https://github.com/scottdevoss/rails_engine)
2. Open the back end repo within VSCode (or your preferred code editor).
3. Open a terminal session within the back end repo, and run the command `bundle install`
4. In the same terminal session, run `rails db:{drop,create,migrate,seed}`
5. In the same terminal session, run `rails server`

## Step Two: Access Rails Engine Endpoints in Postman

1. GET all merchants (http://localhost:3000/api/v1/merchants)

2. GET one merchant (http://localhost:3000/api/v1/merchants/{{merchant_id}})

3. GET a merchant's items (http://localhost:3000/api/v1/merchants/{{merchant_id}}/items)

4. GET all items (http://localhost:3000/api/v1/items)

5. GET one item (http://localhost:3000/api/v1/items/{{item_id}})

6. POST create then delete one item (http://localhost:3000/api/v1/items)

7. PUT update one item (http://localhost:3000/api/v1/items/{{item_id}})

8. GET an item's merchant (http://localhost:3000/api/v1/items/{{item_id}}/merchant)



# Credits, Licensing, and Acknowledgments

<img src="https://mikewilliamson.files.wordpress.com/2010/05/rails_on_ruby.jpg" alt="drawing" width="75"/>

## How to Contribute 

Contributions are welcome! Please feel free to submit a pull request with any contributions, and a member of the team will review it ASAP. You can also contact us using the links below. 

## Authors

  - **Scott DeVoss** - *[LinkedIn](https://www.linkedin.com/in/scott-devoss/), [GitHub](https://github.com/scottdevoss)* 
  - **Isaac Mitchell** - *[LinkedIn](https://www.linkedin.com/in/tmitchellisaac/), [GitHub](https://github.com/tmitchellisaac)* 
 

## License 

This project is not licensed and is open source. 

## Acknowledgments 
  - Technical direction, consultation, and moral support by [Jamison Ordway](https://github.com/jamisonordway) and [Chris Simmons](https://github.com/cjsim89)
  - This project completed by Mod 3 students at [Turing School of Software and Design](https://turing.edu/)
