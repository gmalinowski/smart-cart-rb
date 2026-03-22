
# Authorization Matrix

## Group Policy

## Shopping List Policy

| Action          | owner / admin | group_member | public edit | public view | invited edit | invited view |
|-----------------|---------------|--------------|-------------|-------------|--------------|--------------|
| show            | 1             | 1            | 1           | 1           | 1            | 1            |
| manage          | 1             | -            | -           | -           | -            | -            |
| manage note     | 1             | 1            | 1           | -           | 1            | -            |
| destroy         | 1             | -            | -           | -           | -            | -            |
| share           | 1             | -            | -           | -           | -            | -            |
| gen public link | 1             | -            | -           | -           | -            | -            |
| add to group    | 1             | -            | -           | -           | -            | -            |

- show: show shopping list and its items
- manage: edit list name
- manage note: edit list note
- destroy: delete list
- share: share list with selected users
- gen public link: generate public link for list
- add to group: add list to selected group


## Shopping List Item Policy

| Action  | owner / admin | group_member | public edit | public view | invited edit | invited view |
|---------|---------------|--------------|-------------|-------------|--------------|--------------|
| create  | 1             | 1            | 1           | -           | 1            | -            |
| destroy | 1             | 1            | 1           | -           | 1            | -            |
| update  | 1             | 1            | 1           | -           | 1            | -            |
| toggle  | 1             | 1            | 1           | -           | 1            | -            |

- create: create new item
- destroy: delete item
- update: update item name and list note
- toggle: toggle item status