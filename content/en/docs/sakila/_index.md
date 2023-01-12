---
title: "Sakila"
description: "Sakila"
draft: true
images: []
weight: 600
---

Why?

```go

// ProjectDelete deletes the project having uuid.
func ProjectDelete(ctx context.Context, rb *resource.Bucket, uuid string) error {
 rb.Log.Debugf("Delete project {%s}", uuid)

 tx, err := pgrepo.TxBegin(ctx, rb, nil)
 if err != nil {
  return err
 }

 // Get the DAO
 projDAO, err := pgrepo.ProjectGet(ctx, rb, tx, uuid)
 if err != nil {
  pgrepo.TxRollback(rb, tx)
  return err
 }

 if err := authz.Allowed(ctx, rb, rb.DB, rb.Principal, true, authz.Project(projDAO.UUID), scope.Project); err != nil {
  pgrepo.TxRollback(rb, tx)
  return err
 }

 // TODO: revisit this logic... do we really want to rollback if one
 //  of the sub-projects (DP/CAAS) has been deleted?
 err = doProjectDelete(ctx, rb, tx, projDAO)
 if err != nil {
  pgrepo.TxRollback(rb, tx)
  return err
 }

 if err := tx.Commit(); err != nil {
  return errz.Wrapf(err, "failed to delete project {%s}", projDAO)
 }

 rb.Log.Debugf("Deleted project {%s}", projDAO)

 return nil
}
```
