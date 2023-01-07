---
title: "add"
description: "Add data source"
draft: false
images: []
menu:
  docs:
    parent: "cmd"
weight: 3000
toc: false
---

{{< readfile file="add.help.txt" code="true" lang="text" >}}

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

why

```js
import hljs from 'highlight.js/lib/core';

import javascript from 'highlight.js/lib/languages/javascript';
import json from 'highlight.js/lib/languages/json';
import bash from 'highlight.js/lib/languages/bash';
import htmlbars from 'highlight.js/lib/languages/htmlbars';
import ini from 'highlight.js/lib/languages/ini';
import yaml from 'highlight.js/lib/languages/yaml';
import markdown from 'highlight.js/lib/languages/markdown';

hljs.registerLanguage('javascript', javascript);
hljs.registerLanguage('json', json);
hljs.registerLanguage('bash', bash);
hljs.registerLanguage('html', htmlbars);
hljs.registerLanguage('ini', ini);
hljs.registerLanguage('toml', ini);
hljs.registerLanguage('yaml', yaml);
hljs.registerLanguage('md', markdown);

document.addEventListener('DOMContentLoaded', () => {
document.querySelectorAll('pre code').forEach((block) => {
hljs.highlightBlock(block);
});
});
```

