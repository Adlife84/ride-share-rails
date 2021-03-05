# Getting Started

## What do you need install before get started?
1. Install PostgreSQL
2. Install rbenv or rvm
3. Install Ruby 2.7.2 with rbenv or rvm
4. Install bundler
5. Change to the ride-share-rails directory and run bundle install. (That will install Rails and all required gems).
6. Create the file config/master.key. (Getting the required value from a teammate).
7. Run bin/rails db:setup
8. Run: bundle exec rspec (This will verify that the application is correctly installed, because most of the tests should run correctly. Some tests require firefox, and those will fail unless firefox is present and Capybara is configured to call firefox. It is not necessary, when starting work on the team, to get FIrefox Capybary configured at the start).
9. Run: bin/rails s to start the server.
10. Congratulation! Now you should ready to go :)

## Fork and Clone Repo from GitHub

Fork the repo, then clone your version locally. Then make sure to set the main repo as the upstream source.

```bash
git clone https://github.com/[GITHUBHANDLE]/ride-share-rails.git
cd ride-share-rails
git remote add upstream https://github.com/CodeTheDream/ride-share-rails.git
```

## PostgreSQL install

 ```bash
 brew install postgresql
 bundle install #now it should be work
 ```

## Download Ruby
This project is using ruby 2.7.2. You must have that locally before you can begin working on this project. [Install rbenv](https://github.com/rbenv/rbenv) if you haven't already.

```bash
brew install rbenv
echo 'eval "$(rbenv init -)"' >> ~/.zshrc # or ~/.bash_profile if you're still on bash
source ~/.zshrc # or close the window and relaunch
rbenv install 2.7.2 # and wait for it to finish
```

## Get credentials
Get the master key from one of the main devs on the project. Run the following to make sure the credentials are set correctly. Otherwise, the seeder will complain about not having the correct Google Maps API key when you go to try set up the DB.

## Master Key
Open project files in your text editor (VS Code). 
Make sure that `config/master.key` has the correct master key. 
How to get a Master key you can ask your team.

 ## Build the app and run it
 ```bash
 bundle
 rails db:setup
 ```
After that if you got error with (connections on Unix domain socket "/tmp/.s.PGSQL.5432”?)
just run this comand

```bash
brew services restart postgresql
```

will try again create a table
```bash
rails db:setup # now it should work
rails s # run rails server
```

## Open localhost with the project
Go to your browser `http://localhost:3000/` and log in like an admin. 

# Git Process for CRSN Applications
## CTD Git Workflow
For many CTD projects, we will use a specific Git workflow. This workflow is similar to ones used by many companies. The flow is triangular:

You receive changes to your workspace from the CTD master repository for the project. Some newer repositories use “main” instead of “master” as the name for the master branch.
You create changes in a feature branch on your workspace and push it to your Github fork of the master CTD repository for the project.
You do a pull request. When approved this will merge your changes from your feature branch into the CTD master repository.
You will only have read only access to the CTD master repository for the project. Your changes will be merged by the committers for the project.

## Setting up for this Git Workflow

Fork the CTD master repository for the project into your own github account.
Clone the fork onto your workstation so that you can develop project features.
Add an additional github remote repository to your workspace for the project:
```bash
git remote add upstream # <git url of the master repository>
```

Do a 
```bash
git pull upstream master # to synchronize with the master repository.
```

## Working on a Feature

1. Do not make edits directly to the master branch. 
Instead, create a feature branch using 
```bash
git checkout -b <featurename> 
```
Note: If you forget, there are ways to save your changes and to get the master branch back the way it was. For example: 
1. If you have not committed changes, you can use
```bash
git stash 
```
then create the feature branch, then do 
```bash
git stash apply.
```
2. Work on the feature, periodically committing to your feature branch.
3. Periodically push your commits to github, using
```bash
git push origin <featurename>
```
4. When the feature is complete, tested, and ready, commit and push it once more.
5. Then, checkout the master branch. You need to get any changes that have been made by your coworkers on the project.
6. Do a 
```bash
git pull upstream master # to get those latest changes.
```
7. Then, 
```bash
git checkout <featurename> # to switch back to your feature branch.
```
8. Do 
```bash
git merge master. # This will bring those changes into your feature branch.
```
9. Sometimes you will get merge conflicts. This happens when you and your coworkers are both making changes to the same files. You need to resolve the merge conflicts by editing each file with merge conflicts. The merge conflicts will be marked, and you have to select whether your lines, your coworker’s lines, or both are to be included. You also need to remove the merge conflict markers.
10. If you fixed merge conflicts in any files, add and commit them to complete the merge.
11. Test one more time to make sure the merge didn’t cause a break and that your feature still works.
12. Push your feature branch to github one more time.
13. Login to github and do a pull request for your feature branch. Include git IDs for project committers in the comment for your pull request so that they can review it.
14. If the review determines that changes are needed, make them to the same feature branch. Then repeat the process of pulling the upstream master into the master branch, merging the master branch, and resolving merge conflicts, and push your changes once more, marking the requested changes as resolved.
15. Repeat this process until your feature branch has been merged.
16. Checkout your master branch on your workstation. You can now delete your feature branch using
```bash
git branch -d <featurename>
```
17. Do a 
```bash
git pull upstream master # to pull down your changes into your master branch.
```
18. Do a 
```bash
git push origin master # to push your changes to your github fork master branch.
```
19. Time for a new feature branch!

# Working with a PRIVATE repository
Git Process for Midnight Train Applications
The Warren County Farm to Consumer application will not be open source, because Warren County will own the code. The CARE Alliance Application will not be open source, because it uses a proprietary library. So, we must make both repositories private, and we can’t use forks. Instead, we will use branches for each feature request. There are two branches in continuous use, those being master and development, but these are read/only except for Chuck, Ramiro, and John.

## Setting Up for the Git Process

We will use postgres as the database for this application. Be sure you have postgres installed in your development environment.

Go to the directory where you would like to do your work, and clone the repository:

```bash
git clone https://github.com/[GITHUBHANDLE]/ride-share-rails.git
cd ride-share-rails
bundle install
```

## Git Process for Features

1. 
```bash
git checkout development # (always start your new feature branch here)
```
2. 
```bash
git pull origin development # (make sure you are up to date)
```
3. 
```bash 
git checkout -b your-feature-name
```
4. Develop your feature
5. Add and commit your changes.
```bash
git add . # Additing any changes
git commit -m "Describe what did you change"
```
6. Push your feature branch. This should be done periodically, even before you are done with your feature, so that you don’t lose your work.
```bash
git push
```
7. Test your feature, including Rspec testing. Make any changes necessary to make the tests pass.
8. Commit and push your changes again.
9. 
```bash
git checkout development # you need to merge in any changes that your colleagues have made in the meantime
```
10.
```bash
git pull origin development
```
11. 
```bash
git checkout your-feature-name
```
12. 
```bash
git merge development # now, at this point, if anyone has made changes to the same files you changed, you will need to resolve merge conflicts
```
13. resolve merge conflicts, if any, and add and commit your changes
14. test again to make sure the merge conflict resolution did not break anything
15. Push your changes
```bash
git push
```
16. Do a pull request (PR). The target of the pull request must be the development branch. Make @charlesvincentanderson and @jrmcgarvey as reviewers.
17. Chuck will review your code and may request changes.
18. Make any necessary changes to the your-feature-name branch. Then add, commit, and push again.
19. Once all required changes have been made, Chuck will merge your code.
20. Time for a new feature branch!

# API Documentation

- [Authentication](#authentication)
- [Settings](#settings)
- [Locations](#locations)
- [Availability](#availability)
- [Rides](#rides)

### Authentication

**TODO**

### Settings

**TODO**

### Locations

<details>
<summary>GET /locations</summary>
**Description:**

Return all locations saved by the user.

**Response Example:**
```json
[
  {
    "id": 1,
    "street_address": "123 Pine St.",
    "city": "Durham",
    "state": "NC",
    "zip": "27609"
  },
  {
    "id": 2,
    "street_address": "123 Oak St.",
    "city": "Durham",
    "state": "NC",
    "zip": "27609"
  },
]
```
</details>


<details>
<summary>POST /locations</summary>

**Description:**

Save a location for future use.

**Request Body:**

```json
{
  "street_address": "123 Oak St.",
  "city": "Durham",
  "state": "NC",
  "zip": "27609"
}
```

**Response:**
```json
{
  "id": 3,
  "street_address": "123 Oak St.",
  "city": "Durham",
  "state": "NC",
  "zip": "27609"
}
```

</details>


<details>
<summary>DELETE /locations/:id</summary>

**Description:**

Deletes an address from the list of saved addresses.

**Response:**

{ success: true }
</details>


### Availability

<details>
<summary>GET /availabilities</summary>
**Description:**

Returns an array with all the scheduled available time slots within the given range.

**Params:**

- `start`: timestamp where range begins
- `end`: timestamp where range ends

**Response Example:**
```json
[
  {
    "id": 1,
    "start": "2019-02-07 18:00",
    "end": "2019-02-07 20:00",
    "recurring": true,
    "location": {
      "street_address": "123 Pine St.",
      "city": "Durham",
      "state": "NC",
      "zip": "27609"
    }
  },
  {
    "id": 2,
    "start": "2019-02-08 18:00",
    "end": "2019-02-08 20:00",
    "recurring": false,
    "location": {
      "street_address": "123 Pine St.",
      "city": "Durham",
      "state": "NC",
      "zip": "27609"
    }
  },
  {
    "id": 1,
    "start": "2019-02-14 18:00",
    "end": "2019-02-14 20:00",
    "recurring": true,
    "location": {
      "street_address": "123 Pine St.",
      "city": "Durham",
      "state": "NC",
      "zip": "27609"
    }
  },
]
```
</details>


<details>
<summary>POST /availabilities</summary>

**Description:**

Save a new availability

**Request Body:**

```json
{
  "start_date": "2019-02-14 18:00",
  "end_date": "2019-02-14 20:00",
  "start_time": "2019-02-14 18:00",
  "end_time": "2019-02-14 20:00",
  "recurring": true,
  "location_id": 1
}
```

**Response:**
```json
{
  "id": 6,
  "start": "2019-02-14 18:00",
  "end": "2019-02-14 20:00",
  "recurring": true,
  "location": {
    "street_address": "123 Pine St.",
    "city": "Durham",
    "state": "NC",
    "zip": "27609"
  }
}
```
</details>

<details>
<summary>PUT /availabilities/:id</summary>

**Description:**

Update an existing availability

**Request Body:**

```json
{
  "id": 6,
  "start": "2019-02-14 18:00",
  "end": "2019-02-14 20:00",
  "recurring": true,
  "location": {
    "street_address": "123 Pine St.",
    "city": "Durham",
    "state": "NC",
    "zip": "27609"
  }
}
```

**Response:**
```json
{
  "id": 6,
  "start": "2019-02-14 18:00",
  "end": "2019-02-14 20:00",
  "recurring": true,
  "location": {
    "street_address": "123 Pine St.",
    "city": "Durham",
    "state": "NC",
    "zip": "27609"
  }
}
```
</details>



<details>
<summary>DELETE /locations/:id</summary>

**Description:**

Removes an availability

**Response:**

{ success: true }

</details>


### Rides

<details>
<summary>GET /rides</summary>
**Description:**

Returns an array with all the rides within a given range

**Params:**

- `start`: ***optional*** timestamp where range begins
- `end`: ***optional*** timestamp where range ends
- `states`: ***optional*** list of states the rides are in

***Possible States:***

- `pending`: request has been made but has not been approved by the organization
- `approved`: request has been approved and drivers alerted about ride
- `scheduled`: request has been matched with a driver and scheduled
- `picking-up`: driver has started driving to pick up rider (discuss)
- `dropping-off`: driver has picked up rider and is driving to final destination (discuss)
- `completed`: driver has dropped of rider at final destination
- `canceled`: driver or rider has canceled the ride


**Response Example:**
`GET /api/v1/rides?start=2019-01-01&end=2019-02-01&states=approved,scheduled`
```json
[
  {
    "id": 1,
    "pickupTime": "2019-02-07 18:00",
    "riderName": "John Smith",
    "riderPhone": "919-123-4567",
    "state": "scheduled",
    "pickupLocation": {
      "street_address": "123 Pine St.",
      "city": "Durham",
      "state": "NC",
      "zip": "27609"
    },
    "dropoffLocation": {
      "street_address": "124 Pine St.",
      "city": "Durham",
      "state": "NC",
      "zip": "27609"
    }
  },
  {
    "id": 2,
    "pickupTime": "2019-02-07 18:00",
    "riderName": "Amy Smith",
    "riderPhone": "919-123-4568",
    "state": "approved",
    "pickupLocation": {
      "street_address": "124 Pine St.",
      "city": "Durham",
      "state": "NC",
      "zip": "27609"
    },
    "dropoffLocation": {
      "street_address": "123 Pine St.",
      "city": "Durham",
      "state": "NC",
      "zip": "27609"
    }
  },
]
```
</details>


<details>
<summary>POST /rides/:id/accept</summary>

**Description:**

Driver accepts the ride

**Request Body:**

```json
{
}
```

**Response:**
```json
{
  "id": 2,
  "pickupTime": "2019-02-07 18:00",
  "riderName": "Amy Smith",
  "riderPhone": "919-123-4568",
  "state": "scheduled",
  "pickupLocation": {
    "street_address": "124 Pine St.",
    "city": "Durham",
    "state": "NC",
    "zip": "27609"
  },
  "dropoffLocation": {
    "street_address": "123 Pine St.",
    "city": "Durham",
    "state": "NC",
    "zip": "27609"
  }
}
```
</details>

<details>
<summary>POST /rides/:id/complete</summary>

**Description:**

Driver complete the ride

**Request Body:**
In the future we might want to get feedback from the driver here.
```json
{
}
```

**Response:**
```json
{
  "id": 2,
  "pickupTime": "2019-02-07 18:00",
  "riderName": "Amy Smith",
  "riderPhone": "919-123-4568",
  "state": "complete",
  "pickupLocation": {
    "street_address": "124 Pine St.",
    "city": "Durham",
    "state": "NC",
    "zip": "27609"
  },
  "dropoffLocation": {
    "street_address": "123 Pine St.",
    "city": "Durham",
    "state": "NC",
    "zip": "27609"
  }
}
```
</details>

<details>
<summary>POST /rides/:id/cancel</summary>

**Description:**

Driver cancels the ride

**Request Body:**
```json
{
  "message": "my car broke down"
}
```

**Response:**
```json
{
  "id": 2,
  "pickupTime": "2019-02-07 18:00",
  "riderName": "Amy Smith",
  "riderPhone": "919-123-4568",
  "state": "cancele",
  "pickupLocation": {
    "street_address": "124 Pine St.",
    "city": "Durham",
    "state": "NC",
    "zip": "27609"
  },
  "dropoffLocation": {
    "street_address": "123 Pine St.",
    "city": "Durham",
    "state": "NC",
    "zip": "27609"
  }
}
```
</details>
