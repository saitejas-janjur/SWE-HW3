# Acceptance-Unit Test Cycle

In this assignment you will use a combination of acceptance and unit tests with the Cucumber and RSpec tools to add a "find movies with same director" feature to RottenPotatoes.

**To start: fork this repo as an internal repo within the tamu-edu-students organization and then clone your fork.**

## Learning Goals

After you complete this assignment, you should be able to:
* Create and run simple Cucumber scenarios to test a new feature
* Use RSpec to create unit tests that drive the creation of app code that lets the Cucumber scenario pass
* Understand where to modify a Rails app to implement the various parts of a new feature, since a new feature often touches the database schema, model(s), view(s), and controller(s)


## Introduction and Setup

Clone **your fork** of this repo to your development environment (**do not clone** this reference repo or you'll be unable to push your changes);

e.g. `git clone https://github.com/[your-account]/hw-acceptance-unit-test-cycle`

Once you have the clone of the repo:

1. Change into the rottenpotatoes directory: 

```sh
cd hw-acceptance-unit-test-cycle/rottenpotatoes
```

2. Run 

```sh
bundle config set --local without 'production' && bundle install
```

to make sure all gems are properly installed.  

**NOTE:** If Bundler complains that the wrong Ruby version is installed,

* **rvm**: verify that `rvm` is installed (for example, `rvm --version`) and run `rvm list` to see which Ruby versions are available and `rvm use <version>` to make a particular version active.  If no versions satisfying the Gemfile dependency are installed, you can run `rvm install <version>` to install a new version, then `rvm use <version>` to use it.

* **rbenv**: verify that `rbenv` is installed (for example, `rbenv --version`) and run `rbenv versions` to see which Ruby versions are available and `rbenv local <version>` to make a particular version active.  If no versions satisfying the Gemfile dependency are installed, you can run `rbenv install <version>` to install a new version, then `rbenv local <version>` to use it.

Then you can try `bundle install` again.

3. Create the initial database schema:


```sh
bundle exec rake db:migrate
```

If rails complains that `.../rottenpotatoes/config/boot.rb:6:in '<top (required)>': undefined method 'exists?' for File:Class (NoMethodError)`, then you need to edit `config/boot.rb` line 6 to use `File.exist?` instead of `File.exists?`. Re-attempt the migrations.

If rails complains that `ExecJS::RuntimeUnavailable: Could not find a JavaScript runtime`, then you need to install node.js and re-attempt the migrations: 

```sh
sudo apt install nodejs && bundle exec rake db:migrate
```

If rails complains that `Sprockets::Railtie::ManifestNeededError: Expected to find a manifest file in 'app/assets/config/manifest.js'`, then you need to create that file and put some stuff in it by running the following in the terminal:

```sh
mkdir -p app/assets/config
{
  echo "//= link_directory ../javascripts .js"
  echo "//= link_directory ../stylesheets .css"
} > app/assests/config/manifest.js
```

Then re-run `bundle exec rake db:migrate`.  If rails complains that `Directly inheriting from ActiveRecord::Migration is not supported`, then you need to add the rails version to your migration files, e.g. `class CreateMovies < ActiveRecord::Migration[7.0]`.

This should be the last time you have to attempt to re-run `bundle exec rake db:migrate`.

Now do:

```sh
bundle exec rake db:test:prepare
```

4. Add some more seed data in `db/seeds.rb`.  Then, add it to the database by running

```sh
bundle exec rake db:seed
```

5. Double check that RSpec is correctly set up by running

```sh
bundle exec rspec
```

There are already some RSpec tests written and you should expect them to fail right now.

7. Double check that Cucumber is correctly set up by running `rails cucumber`.  We've provided a couple of scenarios that will fail, which you can use as a starting point, in `features/movies_by_director.feature`.

If rails complains that `Don't know how to build task 'cucumber'`, then you need to run 

```sh
rails generate cucumber:install
```  

Say `Y` to all requests to overwrite.  

<!--Then re-add to `features/support/env.rb` at the top:

```ruby
require 'simplecov'
SimpleCov.start 'rails'
```
-->

Then run 
```sh
rails cucumber
```

<details>
  <summary> 
  Read the Cucumber failure error messages.  The Background step is red.  Why? And how do we fix it?
  </summary>
  <blockquote> 
  The attribute `director` is unknown (doesn't exist) for the `Movie` model.  We must add a `director` field to the `Movie` model.
  </blockquote>
</details>

## Part 1: add a Director field to Movies

### Action! Migration
**Create** and **apply** a migration that adds the Director field to the movies table. The director field should be a string containing the name of the movie’s director. 

* Hint: you may find the `rails generate migration ...` tool useful.
* Hint: you may find the [`add_column` method of `ActiveRecord::Migration`](http://apidock.com/rails/ActiveRecord/ConnectionAdapters/SchemaStatements/add_column) useful.
* Remember that once the migration is applied, you also have to do `bundle exec rake db:test:prepare`
to load the new post-migration schema into the test database.

<details>
  <summary>
  Clearly, now that a new field has been added, we will have to modify the Views so that the user can see and enter values for that field. Do we also have to modify the model file in order for the new field to be "noticed"?
  </summary>
  <blockquote> 
  Nope.  ActiveRecord infers the columns and their data types by inspecting the database.  However, if we wanted to have a validation on that column, we'd have to specifically mention it in a <code>validates</code> call.
  </blockquote>
</details>

<details>
  <summary> 
  If you were to re-run cucumber now, which **previously failing(( steps do you expect to now **pass**?  Why?
  </summary>
  <blockquote> 
  Once this field is added, running <code>rails cucumber</code> should allow the <code>Background:</code> steps to pass, since they just use ActiveRecord directly to create movies with a Director field.  But the other scenarios all manipulate the user interface (the views), which you have not yet modified, so they will not yet pass.
  </blockquote>
</details>

### Action! Run Cucumber
Verify that the Cucumber steps you expect to pass actually do pass by running

```sh
rails cucumber
```

<details>
  <summary> 
  Read the Cucumber results.  You should see that every step of the scenarios are undefined. What will you have to do to address that?  Specifically, how do you resolve the very first of those: Undefined step: "I go to the edit page for "Alien"" 
  </summary>
  <blockquote> 
  You'll have to write a definition. Right now, it's not a bad idea to write these steps in `features/step_definitions/movie_steps.rb`.
  </blockquote>
</details>

### Action! Define Steps, Implement a Step

1. As a first step, you can simply copy+paste the snippets that Cucumber gives you (at the bottom of the report) into `movie_steps.rb`.  **Do it now.**
2. Run Cucumber again: `rails cucumber`.
   * See that all steps are now pending or skipped (because an earlier step is pending).
3. Implement the step `I go to the edit page for {string}`
   * You will find these to be helpful:
     * [Capybara API documentation](https://rubydoc.info/github/teamcapybara/capybara/master)
     * [Active Record Basics - Ruby on Rails Guides](https://guides.rubyonrails.org/active_record_basics.html)

<details>
  <summary>Hints for the desperate and depraved.</summary>
    <blockquote>
      Find the movie by title, then visit the edit movie path for that movie.
    </blockquote>
</details>

### Action! Run Cucumber
Verify that the Cucumber steps you expect to pass actually do pass by running

```sh
rails cucumber
```

###  Action! Implement Another Step

1. Implement the step `I fill in {string} with {string}`
2. Run cucumber to see the step is failing for the right reason.

<details>
  <summary>What is the right reason for this step to fail?</summary>
  <blockquote> 
  Unable to find field "Director" that is not disabled (Capybara::ElementNotFound).  The edit page (app/views/movies/edit.html.erb) does not have a director field.  So, we must add it!
  </blockquote>
</details>

### Action! Modify the View to Be Aware of the `director` field

Based on the above, you should be able to modify the view to be "aware" of the new Director field.

So, do that now.

### Action! Run Cucumber
Verify that the Cucumber steps you expect to pass actually do pass by running

```sh
rails cucumber
```

The first two steps of `Scenario: add director to existing movie` should be green (passing).  The next step (`And I press "Update Movie Info"`) should be pending.

This is the end of Part 1.

## Part 2: use Acceptance and Unit tests to get new scenarios passing

We've provided three Cucumber scenarios in the file `features/movies_by_director.feature` to drive creation of two happy paths and one sad path of Search for Movies by Director.

### Scenario: Add Director to Existing Movie
The first expects to be able to add director info to an existing movie, and doesn't require creating any new views or controller actions, but does require modifying existing views and the movie controller and implementing steps.

In Part 1, we added the director field to movies, defined all the steps (but left most as TODO), implemented two steps, and added the director field to the edit view.

The next step is to press "Update Movie Info" (the submit button for the edit movie form).

1. Implement the step `And I press {string}`.
2. Run cucumber.
3. Verify that the step passes.
   * Did you expect it to pass? Why (not)?

So far, so good, no?

The last step of this scenario is to verify that the director field was updated in the database.

1. Implement the step `the director of {string} should be {string}`
2. Run cucumber.
3. Verify that the step fails.
   * Did you expect it to fail? Why (not)?

<details>
  <summary>
  Besides modifying the view, will we have to modify anything in the controller?  If so, what? 
  </summary>
  <blockquote> 
  Yes: we have to add <code>:director</code> to the list of movie attributes in the <code>def movie_params</code> method in <code>movies_controller.rb</code>.  Otherwise, even if that value is available as <code>params["movie"]["director"]</code>, it will be "scrubbed" by the <code>require</code> and <code>permit</code> calls on <code>params</code> before the controller actions are able to see it.
  </blockquote>
</details>

<details>
  <summary>
  Which controller actions, specifically, would fail to work correctly if we didn't make the above change?
  </summary>
  <blockquote> 
  <code>create</code> and <code>update</code> would fail, since they are the ones that expect a form submission in <code>params</code> in which <code>params["movies"]</code> should appear.  The other actions do not expect or manipulate this form (and do not call the helper function <code>movie_params</code>) so they would not be affected.
  </blockquote>
</details>

### Action! Update the Movies Controller to Add Director to the Permitted Movie Parameters

1. Run Rspec: `bundle exec rspec`
2. Verify that the `MoviesController updates actually does the update` example fails.
   * If this test did not exist yet ([you're welcome](https://www.youtube.com/watch?v=79DijItQXMM)), we would create it now.
4. In `app/controllers/movies_controller.rb`, in the method `movie_params`, add `:director` to the `:permit` argument list.
5. Run Rspec: `bundle exec rspec`
6. Verify that none of the examples are failing
   * 4 *are* pending, though... you'll come back to these in a bit.
8. Run cucumber to verify that the step passes.

### Action! Celebrate!

All steps in the first scenario should be passing!

### Scenario: Find Movies with the Same Director

The second scenario that we have provided for you expects to be able to click a new link on a movie details page "Find Movies with Same Director", and shows all other movies that share the same director as the displayed movie.  For this you'll have to modify the existing Show Movie view, and you'll have to add a route, view and controller method for Find With Same Director.  

### Action! Implement the Step Definitions and Specs to Drive Modifications to the Code Base

**Write tests first.**

You will find the [RSpec documentation](https://rspec.info/documentation/) helpful.

Going one Cucumber step at a time, implement the step definitions until failure, then use RSpec to create the appropriate controller and model specs to drive the creation of the new controller and model methods.  At the least, you will need to write tests to drive the creation of: 

* a RESTful route for Find Similar Movies (HINT: use the 'match' syntax for routes as suggested in "Non-Resource-Based Routes" in the [Rails Routing documentation](http://guides.rubyonrails.org/routing.html)). You can also use the key `:as` to specify a name to generate helpers (i.e. search_directors_path)  Note: Tests can fail if the route is not correct (you can test route existence directly in a spec).
* a controller method to receive the click on "Find with Same Director", and grab the `id` (for example) of the movie that is the subject of the match (i.e. the one we're trying to find movies similar to) 
* a model method in the `Movie` model to find movies whose director matches that of the current movie.

<details>
  <summary> 
  Would this model method be a class method or instance method?
  </summary>
  <blockquote> 
  Technically it could be either.  You could call it on a movie, the idea being that it returns other movies with the same director as its receiver, e.g. <code>movie.others_by_same_director()</code>.  Or you could define it as a class method, e.g. <code>Movie.with_director(director)</code>. In fact, it's great practice to write it both ways.
  </blockquote>
</details>

Note: we have provided stubs for some controller and model specs:

```ruby
# spec/controllers/movies_controller_spec.rb

describe "when trying to find movies by the same director" do
  it "returns a valid collection when a valid director is present"
    # TODO(student): implement this test
end
```

```ruby
# spec/models/movie_spec.rb

describe "others_by_same_director method" do
  it "returns all other movies by the same director"
    # TODO(student): implement this test

  it "does not return movies by other directors"
    # TODO(student): implement this test
end
```

**To Be Clear:** You should follow this process:

1. Run Cucumber: `rails cucumber`.
2. Verify that all steps in the scenario are skipped, pending, or passed.
3. Implement the next step in the scenario.
4. Run Cucumber: `rails cucumber`.
5. Verify that the step is failing.
   * If it is passing, ask yourself: "Is that supposed to happen?"
     * No: fix your step definition.
     * Yes: add and commit changes, then go to step 3 to start working on the next step
7. Run Rspec: `bundle exec rspec`.
8. Verify that all examples passing or pending.
9. Create (or implement) a spec that verifies the correctness of the functionality you want to implement (tests the code you wish you had).
10. Run Rspec: `bundle exec rspec`.
11. Verify that the newly-implemented example is failing.
    * If it is passing, ask yourself: "Is that supposed to happen?"
      * No: fix your spec.
      * Yes: add and commit changes, then continue.
13. Write just enough code to turn the example green (passing).
   * e.g. add a route, create a controller method, create a model method, etc.
14. Until all functional specifications for the current unit are expressed in Rspec, go to step 9.
15. Add and commit changes: `git add . ; git commit -m "<message>"`.
16. Run Cucumber: `rails cucumber`.
17. Verify that the step is passing.
    * If it is failing, ask yourself:
      * "Did I miss a functional requirement?" (if so, your specs, and therefore also your code, are incomplete. go to step 9 to write more specs to drive more code.)
      * "Are my specs wrong?" (if so, your code is "correct" against and invalid spec.  go to step 9 to fix your spec and fix your code.)
      * "Is my step definition wrong?" (if so, your specs might be invalid and your code might be doing the wrong thing. go to step 3 to fix your step definition, fix your specs, fix your code.)
    * If it is passing, add and commit changes, then go to step 3 to start working on the next step.


### Scenario: Can't Find Movies With the Same Director If We Don't Know the Director

The third scenario that we have provided for you handles the sad path: when the current movie has no director info but we try to do "Find Movies with Same Director" anyway.

### Action! Implement the Step Definitions and Specs to Drive Further Modifications to the Code Base

**Write tests first.**

Again, going one Cucumber step at a time, use RSpec to create the appropriate controller and model specs to drive the development of the functionality to support the expected behavior.

Note: we have provided a stub for a controller spec:

```ruby
# spec/controllers/movies_controller_spec.rb

describe "when trying to find movies by the same director" do
  it "redirects to index with a warning when no director is present"
    # TODO(student): implement this test
end
```

It's up to you to decide whether you want to detect the sad path of "no director" in the controller method or in the model method, but you must provide a test for whichever one you do. **Remember to include the line** `require 'rails_helper'` at the top of every `*_spec.rb` file.

## Part 3: Code Coverage

Notice that the Gemfile includes the SimpleCov gem, and that the first two lines of `rails_helper.rb` file (which you should be `require`ing at the top of every `*_spec.rb` file) as well as the first and only two lines of `features/support/simplecov.rb` (which Cucumber loads automatically when run) start the SimpleCov test coverage measurement.

Each time you run `rspec` or `cucumber`, SimpleCov  generates a report in a directory named `coverage/`. Since both RSpec and Cucumber are so widely used, SimpleCov can intelligently merge the results, so running the tests for Rspec does not overwrite the coverage results from Cucumber and vice versa.

To see the results, open `coverage/index.html` with a browser or HTML preview extension to view your coverage report.  If you cannot view the page remotely, download the coverage folder and view it locally.

Improve your test coverage to **at least 90%** by adding unit tests for untested or undertested code and by removing code which you do not need.

## Part 4: Add Tests

1. Add at least one (1) more Cucumber scenario, to bring the number of scenarios to at least four (4).
2. Add at least three (3) more Cucumber steps, to bring the number of steps to at least twenty (20). 
3. Add at least three (3) more RSpec examples, to bring the number of exampels to at least ten (10).

## Part 5: Code Quality

run `rubocop` and `rubycritic` and address most, if not all, of the issues they find.

## Submission:

Submit a zip file containing the following files and directories of your app:

* `app/`
* `config/`
* `db/migrate`
* `features/`
* `spec/`
* `Gemfile`

If you modified any other files, please include them too. If you are on a *nix based system, navigate to the root directory for this assignment and run

```sh
$ cd ..
$ zip -r submission.zip rottenpotatoes/app/ rottenpotatoes/config/ rottenpotatoes/db/migrate rottenpotatoes/features/ rottenpotatoes/spec/ rottenpotatoes/Gemfile
```

This will create the file `submission.zip`, which you will submit.

IMPORTANT NOTE: Your submission must have the `rottenpotatoes/` folder, so that it looks like this:

```
$ tree
.
└── rottenpotatoes
    ├── Gemfile
    ├── app
    ├── config
    ...
```
