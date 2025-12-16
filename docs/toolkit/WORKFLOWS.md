# Common Workflows for InvenTree Plugin Development

**Audience:** Users and AI Agents | **Category:** How-To Guides | **Purpose:** Step-by-step workflows for common plugin development tasks | **Last Updated:** 2025-12-12

---

Step-by-step guides for common tasks. Follow these workflows when developing plugins.

---

## 📦 Understanding Plugin Deployment

### Two Deployment Methods

**Single-File Plugins (Simple):**
- Just a `.py` file dropped into InvenTree's plugins directory
- InvenTree auto-discovers and loads it
- Good for: Quick prototypes, simple backend plugins
- No build step needed

**Packaged Plugins (Professional):**
- Full Python package with structure (what this toolkit creates)
- Built as `.whl` file, installed via pip
- Good for: Production use, plugins with dependencies/frontend
- Requires build step (handled by toolkit)

**This toolkit supports both methods, but is optimized for packaged plugins.**

---

## 🆕 Workflow 1: Create a Brand New Plugin

**When to use:** Starting a completely new plugin from scratch

### Method 1: Copilot-Guided Creation (Recommended)

Use this method when you want intelligent recommendations for which mixins to use.

1. **Open Copilot Chat** in VS Code (`Ctrl+I` or Chat panel)

2. **Use the guided creation prompt:**
   ```
   @workspace I want to create a new InvenTree plugin. Follow the guided creation process in copilot/copilot-guided-creation.md
   ```

3. **Follow Copilot's guidance:**
   - Answer questions about what your plugin should do
   - Review mixin recommendations with explanations
   - Get formatted answers to copy/paste into plugin-creator

4. **Run the creation command:**
   ```powershell
   .\scripts\New-Plugin.ps1
   ```
   Copy/paste each answer as prompted (plugin-creator is interactive).

**Why use this:** Intelligent recommendations based on your requirements, no need to know InvenTree internals upfront.

### Method 2: Direct Plugin Creation

Use this if you already know exactly which mixins you need.

1. **Run the plugin creator:**
   ```powershell
   .\scripts\New-Plugin.ps1
   ```

2. **Answer the interactive prompts:**
   - Plugin name, description, author info
   - Select license (usually MIT)
   - Choose mixins (spacebar to toggle, enter to confirm)
   - Frontend features (if using UserInterfaceMixin)
   - Translation support (usually no)
   - Git integration (usually yes)
   
   See `copilot/copilot-guided-creation.md` for complete question reference.

3. **The plugin is created in:** `plugins/YourPluginName/`

### Post-Creation Setup: Code Quality Tools

**Every new plugin is scaffolded with:**
- **Biome** (`biome.json`) - Frontend linter/formatter for TypeScript/React
- **Pre-commit config** (`.pre-commit-config.yaml`) - Automatic code quality checks
- **Ruff** (via pre-commit) - Python linter/formatter

**To activate these tools:**

1. **Create virtual environment** (first time only):
   ```powershell
   cd plugins/YourPluginName
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   ```

2. **Install pre-commit** (first time only):
   ```powershell
   pip install pre-commit
   pre-commit install
   ```

3. **Run initial formatting** (first time only):
   ```powershell
   pre-commit run --all-files
   ```
   This auto-formats all Python and TypeScript files to match best practices.

**From now on**, every time you commit:
- Ruff automatically formats and lints Python code
- Biome automatically formats and lints TypeScript/React code
- Commits are blocked if unfixable issues are found

**Manual checks** (optional):
```powershell
# Check frontend code
cd frontend
npm run lint        # Check for issues
npm run lint:fix    # Auto-fix issues

# Check all code
pre-commit run --all-files
```

**Why this matters:**
- Consistent code style across all plugins
- Catches common errors before they reach the server
- Follows Python PEP 8 and modern TypeScript best practices
- No manual formatting needed

### Recommended Development Workflow

**For plugins with frontends**, follow this workflow to ensure GitHub installations work:

```powershell
# 1. Make code changes to Python or TypeScript files

# 2. Build plugin (compiles frontend to static/ folder)
.\scripts\Build-Plugin.ps1 -Plugin "YourPlugin"

# 3. Commit everything including built static/ assets
git add .
git commit -m "Your changes"  # Pre-commit hooks run automatically

# 4. Push to GitHub (so git-based installations work)
git push

# 5. Deploy to server for testing
.\scripts\Deploy-Plugin.ps1 -Plugin "YourPlugin" -Server staging
```

**Why commit `static/` folder?**
- Users installing via `pip install git+https://github.com/...` need the built frontend
- The build happens on your machine, not theirs
- Without it, the plugin frontend won't work from GitHub installations

**Important:** If your plugin has a `<plugin_name>/.gitignore` file that blocks `static/`, remove it:
```powershell
Remove-Item <plugin_name>/.gitignore -Force
git add <plugin_name>/static/
```

---

## ✏️ Workflow 2: Add a New Setting to Your Plugin

**When to use:** You want users to configure your plugin

### Steps:

1. **Open** `your-plugin/your_package/core.py`

2. **Find the SETTINGS dictionary** (or add it if it doesn't exist)

3. **Add your setting:**
   ```python
   SETTINGS = {
       'YOUR_SETTING_NAME': {
           'name': 'Display Name',
           'description': 'What this setting controls',
           'default': 'default value',
           'validator': str,  # or int, bool, etc.
       }
   }
   ```

4. **Use the setting in your code:**
   ```python
   def some_method(self):
       value = self.get_setting('YOUR_SETTING_NAME')
       # Use the value...
   ```

5. **Build and deploy:**
   ```powershell
   # Deploy automatically builds first
   .\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin" -Server staging
   ```

   **Note:** You can run `.\scripts\Build-Plugin.ps1` separately if you want to test the build without deploying.

6. **In InvenTree:** Go to Settings → Plugins → Your Plugin → Configure

---

## 🌐 Workflow 3: Add a Custom API Endpoint

**When to use:** You want to expose data or functionality via REST API

### Prerequisites:
- Your plugin must use `UrlsMixin`

### Steps:

1. **Open** `your-plugin/your_package/views.py`

2. **Create a new view class:**
   ```python
   from rest_framework import permissions
   from rest_framework.response import Response
   from rest_framework.views import APIView
   
   class MyCustomView(APIView):
       permission_classes = [permissions.IsAuthenticated]
       
       def get(self, request):
           data = {
               'message': 'Hello!',
               # Add your data here
           }
           return Response(data, status=200)
   ```

3. **Open** `your-plugin/your_package/core.py`

4. **Register the URL in `setup_urls` method:**
   ```python
   def setup_urls(self):
       from django.urls import path
       from .views import MyCustomView
       
       return [
           path('my-endpoint/', MyCustomView.as_view(), name='my-endpoint'),
       ]
   ```

5. **Build and deploy:**
   ```powershell
   # Deploy automatically builds first
   .\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin" -Server staging
   ```

6. **Test it:** Go to `https://your-server/plugin/your-plugin-slug/my-endpoint/`

---

## 🎨 Workflow 4: Add a Custom Panel to Part Page

**When to use:** You want to show custom information on InvenTree pages

### Prerequisites:
- Your plugin must use `UserInterfaceMixin`
- Your plugin must have frontend code

### Steps:

1. **Open** `your-plugin/frontend/src/Panel.tsx`

2. **Create your panel component:**
   ```typescript
   import { Alert, Text } from '@mantine/core';
   import type { InvenTreePluginContext } from '@inventreedb/ui';
   
   function MyPanel({ context }: { context: InvenTreePluginContext }) {
     const partId = context.id;
     
     return (
       <Alert title="My Custom Panel" color="blue">
         <Text>Part ID: {partId}</Text>
         {/* Add your UI here */}
       </Alert>
     );
   }
   
   export function renderMyPanel(context: InvenTreePluginContext) {
     return <MyPanel context={context} />;
   }
   ```

3. **Open** `your-plugin/your_package/core.py`

4. **Register the panel in `get_ui_panels` method:**
   ```python
   def get_ui_panels(self, request, context: dict, **kwargs):
       panels = []
       
       if context.get('target_model') == 'part':
           panels.append({
               'key': 'my-panel',
               'title': 'My Custom Panel',
               'icon': 'ti:info-circle',
               'source': self.plugin_static_file('Panel.js:renderMyPanel'),
           })
       
       return panels
   ```

**Advanced: Conditionally show panels based on instance properties:**

```python
def get_ui_panels(self, request, context: dict, **kwargs):
    panels = []
    
    if context.get('target_model') == 'part':
        part_id = context.get('target_id')
        
        if part_id:
            from part.models import Part
            
            try:
                part = Part.objects.get(pk=part_id)
                
                # Only show for assemblies
                if part.assembly:
                    panels.append({
                        'key': 'my-panel',
                        'title': 'Assembly Panel',
                        'icon': 'ti:box',
                        'source': self.plugin_static_file('Panel.js:renderMyPanel'),
                    })
            except Part.DoesNotExist:
                pass
    
    return panels
```

5. **Deploy (automatically builds if needed):**
   ```powershell
   .\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin" -Server staging
   ```

6. **View it:** Open a Part page in InvenTree - your panel will appear!

---

## 🎯 Workflow 5: Add a Dashboard Widget

**When to use:** You want to show information on the InvenTree dashboard

### Prerequisites:
- Your plugin must use `UserInterfaceMixin`
- Your plugin must have frontend code

### Steps:

1. **Open** `your-plugin/frontend/src/Dashboard.tsx`

2. **Create your dashboard widget:**
   ```typescript
   import { Card, Text, Stack } from '@mantine/core';
   import type { InvenTreePluginContext } from '@inventreedb/ui';
   
   function MyDashboard({ context }: { context: InvenTreePluginContext }) {
     return (
       <Stack>
         <Text size="xl">My Dashboard Widget</Text>
         <Text>Show statistics here...</Text>
       </Stack>
     );
   }
   
   export function renderMyDashboard(context: InvenTreePluginContext) {
     return <MyDashboard context={context} />;
   }
   ```

3. **Open** `your-plugin/your_package/core.py`

4. **Register the dashboard item in `get_ui_dashboard_items` method:**
   ```python
   def get_ui_dashboard_items(self, request, context: dict, **kwargs):
       items = []
       
       items.append({
           'key': 'my-dashboard',
           'title': 'My Dashboard Widget',
           'icon': 'ti:chart-bar',
           'source': self.plugin_static_file('Dashboard.js:renderMyDashboard'),
       })
       
       return items
   ```

5. **Deploy** (automatically builds):
   ```powershell
   .\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin" -Server staging
   ```

6. **View it:** Go to InvenTree home/dashboard page

---

## 🔄 Workflow 6: Call Your Plugin API from Frontend

**When to use:** Your frontend needs data from your custom API endpoint

### Prerequisites:
- You have a custom API endpoint (see Workflow 3)
- You have a frontend panel or dashboard

### Steps:

1. **In your frontend component** (e.g., `Panel.tsx`):
   ```typescript
   import { useQuery } from '@tanstack/react-query';
   import { Text, Loader } from '@mantine/core';
   
   function MyPanel({ context }: { context: InvenTreePluginContext }) {
     
     const dataQuery = useQuery(
       {
         queryKey: ['myPluginData'],
         queryFn: async () => {
           const url = '/plugin/my-plugin-slug/my-endpoint/';
           const response = await context.api.get(url);
           return response.data;
         }
       },
       context.queryClient
     );
     
     if (dataQuery.isLoading) return <Loader />;
     if (dataQuery.error) return <Text color="red">Error!</Text>;
     
     return (
       <div>
         <Text>{dataQuery.data.message}</Text>
       </div>
     );
   }
   ```

2. **Build and deploy** as usual

---

## 🔧 Workflow 7: Live Frontend Development

**When to use:** You're actively editing frontend code and want instant feedback

### Prerequisites:
- You have InvenTree development server running
- Your plugin has frontend code

### Steps:

1. **Start InvenTree frontend dev server** (in InvenTree repo):
   ```bash
   invoke dev.frontend-server
   ```
   This should run on `http://localhost:5173`

2. **Start your plugin dev server:**
   ```powershell
   # Frontend auto-rebuilds during deployment
   # Edit code, then run Build-Plugin.ps1 to see changes
   ```
   This runs on `http://localhost:5174`

3. **Open InvenTree in browser:** `http://localhost:5173`

4. **Navigate to a page** where your panel appears

5. **Edit your .tsx files** in VS Code

6. **See changes instantly** in the browser (auto-reload)!

7. **Press Ctrl+C** to stop when done

8. **When ready, deploy** (auto-builds for production):
   ```powershell
   .\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin" -Server staging
   ```

---

## 📦 Workflow 8: Deploy Plugin Updates

**When to use:** You made changes and want to test/deploy them

### For Staging (Testing):

**Deploy** (automatically builds if source changed):
**Deploy** (automatically builds if source changed):
```powershell
.\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin" -Server staging
```

The script automatically:
- Checks if source files changed
- Rebuilds if needed
- Uploads and installs via pip
- Restarts InvenTree

**Test your changes** in the browser

### For Production:

**After testing on staging**, deploy to production:
```powershell
.\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin" -Server production
```

You'll be asked to confirm - type `yes` to proceed.

### Optional: Build Without Deploying

If you just want to build (for testing locally or distribution):
```powershell
.\scripts\Build-Plugin.ps1 -Plugin "your-plugin"
```

---

## 🐛 Workflow 9: Debugging Common Issues

### Issue: Plugin doesn't appear in InvenTree

**Check:**
1. Is the plugin in the correct directory on the server?
2. Did you restart InvenTree after deploying?
3. Check InvenTree logs: `docker logs inventree` or server logs
4. Verify `__init__.py` has `PLUGIN_VERSION`
5. Verify `core.py` has the plugin class

### Issue: Frontend panel doesn't show

**Check:**
1. Is the `static/` folder created with `.js` files? (Deploy auto-builds)
2. Did you register the panel in `get_ui_panels()` in `core.py`?
3. Does the panel have the right target_model? (e.g., 'part')
4. Check browser console for JavaScript errors
5. See Workflow 10 for detailed panel troubleshooting

### Issue: API endpoint returns 404

**Check:**
1. Is `UrlsMixin` in your plugin's mixin list?
2. Did you register the URL in `setup_urls()`?
3. Is the URL path correct? Check the plugin slug
4. Did you restart InvenTree?

### Issue: Frontend build fails

**Try:**
1. Delete `node_modules/`: `Remove-Item -Recurse frontend/node_modules`
2. Reinstall: `npm install` in the frontend directory
3. Check for TypeScript errors in your `.tsx` files
4. Look at the error message - it usually tells you what's wrong

---

## 📝 Workflow 10: Adding Database Models

**When to use:** You need to store custom data in the database

### Prerequisites:
- Your plugin must use `AppMixin`

### Steps:

1. **Open** `your-plugin/your_package/models.py`

2. **Define your model:**
   ```python
   from django.db import models
   from django.contrib.auth.models import User
   
   class MyCustomModel(models.Model):
       user = models.ForeignKey(User, on_delete=models.CASCADE)
       data = models.CharField(max_length=200)
       created = models.DateTimeField(auto_now_add=True)
       
       class Meta:
           app_label = "your_package_name"
   ```

3. **Create migrations:**
   ```powershell
   cd plugins/your-plugin
   python manage.py makemigrations your_package_name
   ```

4. **Deploy and run migrations on server:**
   - Deploy the plugin
   - Run: `python manage.py migrate your_package_name`

5. **Use the model in your code:**
   ```python
   from .models import MyCustomModel
   
   # Create
   obj = MyCustomModel.objects.create(user=request.user, data="test")
   
   # Query
   objects = MyCustomModel.objects.filter(user=request.user)
   ```

---

## 🚀 Workflow 10: Deploy and Test Plugin on Server

**When to use:** Testing your plugin in a real InvenTree environment

### Understanding Deployment for Packaged Plugins

**CRITICAL:** Packaged plugins with frontends MUST be installed via pip, not copied as source files.

**Why?** Because:
- Frontend assets are bundled into the `.whl` package during build
- InvenTree serves static files from the installed package location
- Copying source files bypasses the package installation process
- The static files won't be in the right location for InvenTree to find them

### Deployment Steps:

1. **Deploy to staging:**
   ```powershell
   .\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin" -Server staging
   ```
   
   What this does:
   - Checks if source files changed since last build
   - Automatically rebuilds if needed (creates `.whl` file)
   - Uploads the `.whl` file to the server
   - Runs `pip install --upgrade --force-reinstall` in the Docker container
   - Restarts InvenTree
   - Cleans up temporary files

**Optional:** Build without deploying (for local testing or distribution):
```powershell
.\scripts\Build-Plugin.ps1 -Plugin "your-plugin"
```

3. **Enable the plugin in InvenTree:**
   - Go to Admin > Plugins
   - Find your plugin
   - Click the toggle to activate it
   - Wait a few seconds for InvenTree to load it

### Testing UI Panels:

**Important:** Panels only appear if ALL conditions are met:

1. ✅ Plugin is installed via pip (not copied as source)
2. ✅ Plugin is activated in InvenTree admin
3. ✅ `get_ui_panels()` returns panel configuration
4. ✅ Conditions in your code are satisfied (e.g., `if part.assembly`)
5. ✅ You're viewing the correct page type (e.g., part detail page)

**How to verify panel is working:**

1. **Check plugin is installed:**
   ```powershell
   # Via API
   $headers = @{Authorization = "Token YOUR_API_KEY"}
   Invoke-RestMethod -Uri "https://your-server/api/plugins/" -Headers $headers
   ```
   
   Look for your plugin in the list with `active: True`

2. **Check API returns your panel:**
   ```powershell
   # For a part panel (replace 123 with actual part ID)
   Invoke-RestMethod -Uri "https://your-server/api/plugins/ui/features/panel/?target_model=part&target_id=123" -Headers $headers
   ```
   
   Your panel should appear in the returned JSON

3. **Common issues:**

   | Symptom | Likely Cause | Fix |
   |---------|-------------|-----|
   | Plugin not in list | Not installed | Re-run Deploy-Plugin.ps1 |
   | `active: False` | Not enabled | Enable in Admin > Plugins |
   | Panel not in API response | Code condition not met | Check your `if` statements in `get_ui_panels()` |
   | Panel in API but not UI | Static file issue | Rebuild and redeploy |
   | Wrong `package_path` in plugin info | Source files interfering | Remove old source files from plugin directory |

### Testing Workflow:

1. **Make a code change** (e.g., change panel title)

2. **Deploy** (automatically rebuilds and deploys):
   ```powershell
   .\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin" -Server staging
   ```

3. **Refresh browser** - changes should appear immediately (InvenTree restarted automatically)

5. **If changes don't appear:**
   - Hard refresh: `Ctrl+Shift+R` or `Ctrl+F5`
   - Check browser console for errors
   - Verify plugin is still enabled in admin

### Debugging Panel Issues:

**Panel doesn't show at all:**

```python
# Temporarily remove all conditions to test
def get_ui_panels(self, request, context: dict, **kwargs):
    panels = []
    
    # Show on ALL part pages for testing
    if context.get('target_model') == 'part':
        panels.append({
            'key': 'test-panel',
            'title': 'TEST - Panel Working!',
            'icon': 'ti:test-pipe',
            'source': self.plugin_static_file('Panel.js:renderMyPanel'),
        })
    
    return panels
```

If this shows up, gradually add back your conditions to find which one fails.

**Check what InvenTree sees:**

```python
def get_ui_panels(self, request, context: dict, **kwargs):
    # Log what you're receiving
    import logging
    logger = logging.getLogger('inventree')
    logger.info(f"Panel context: {context}")
    
    # Your normal code...
```

Then check InvenTree logs:
```powershell
ssh your-server "docker logs inventree-server 2>&1 | grep 'Panel context'"
```

### Production Deployment:

When ready for production:

```powershell
.\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin" -Server production
```

You'll be asked to confirm - type `yes` to proceed.

---

## 💡 Pro Tips

### Tip 1: Use Copilot for Repetitive Code
When writing similar code (e.g., multiple settings, multiple panels), write one example and let Copilot suggest the rest.

### Tip 2: Test on Staging First
**Always** test on staging before production. The scripts make this easy.

### Tip 3: Keep Notes
Add comments in your code explaining what things do - helps future you!

### Tip 4: Version Control
Each plugin can be its own git repository. Commit often!

### Tip 5: Read Error Messages
Most errors tell you exactly what's wrong and where. Don't skip reading them!

---

## 🆘 When You're Stuck

1. **Read the error message carefully**
2. **Check the copilot/COPILOT-GUIDE.md** for relevant prompts
3. **Ask Copilot** - paste the error and ask for help
4. **Check InvenTree docs:** https://docs.inventree.org/
5. **Look at the template plugin** created by plugin-creator for examples

---

## 📚 Next Steps

Once you're comfortable with these workflows:
- Explore other mixins (EventMixin, ScheduleMixin, etc.)
- Add more complex frontend components
- Integrate with external APIs
- Create reusable components

Happy plugin development! 🚀
