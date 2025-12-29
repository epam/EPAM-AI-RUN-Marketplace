# Guardrail Configuration Guide

## Overview

Guardrails provide content safety and filtering across your Codemie workspace. After installing AWS Bedrock Guardrails, you can configure them at multiple levels: project-wide, per-assistant, per-workflow, or per-knowledge-base.

---

## Quick Start

### Configuring Guardrails During Entity Creation

When creating entities in Codemie, you can assign guardrails directly:

1. **During Assistant Creation**:
   - When creating a new assistant, navigate to the **Guardrails** section
   - Click **Add Guardrail**
   - Select guardrails to apply to this assistant
   - Configure source (Input, Output, or Both) and mode (All or Filtered)
   - Complete assistant creation

2. **During Workflow Creation**:
   - Similar guardrail assignment panel appears when creating workflows
   - Configure guardrails before saving the workflow

3. **During Knowledge Base Creation**:
   - Assign guardrails to filter retrieved content
   - Useful for sensitive data sources
   - Note: Re-indexing is required for guardrails to apply to existing data sources

---

## Guardrail Assignment Levels

### 1. Project-Level Guardrails (Default)

Apply guardrails to all entities in a project:

1. Navigate to the installed guardrail details page
2. Click **Assign** button
3. In the Assignment popup, enable the switch for **"Apply to all project [entity type]"**
4. Configure:
   - **Source**: Input, Output, or Both
   - **Mode**: All or Filtered
5. Click **Assign**

**Effect**: All entities of the selected type in the project inherit these guardrails by default. For knowledge bases, re-indexing is required to apply guardrails to existing data sources.

### 2. Entity-Level Guardrails

Assign guardrails to specific entities:

#### Using the Guardrail Assignment Popup

1. From the installed guardrail details page, click **Assign**
2. In the Assignment popup, select the tab for the entity type:
   - **Assistants**
   - **Workflows**  
   - **Data Sources** (Knowledge Bases)
3. The switch for project-wide assignment will be shown at the top
4. Below that, manually select specific entities from the dropdown
5. For each entity, configure:
   - **Source**: Input (user messages/input), Output (responses/results), or Both
   - **Mode**: All or Filtered
6. Click **Assign** to save

#### From Entity Details

Alternatively, assign guardrails from the entity itself:

**For Assistants:**
1. Go to **Assistants** → Select your assistant
2. Navigate to **Guardrails** section in the details view
3. View current guardrail assignments (both project-level and entity-specific)
4. To add more, use the Guardrail Assignment popup as described above

**For Workflows:**
1. Go to **Workflows** → Select your workflow
2. Navigate to **Guardrails** section
3. View and manage guardrail assignments

**For Knowledge Bases:**
1. Go to **Data Sources** → Select your knowledge base
2. Navigate to **Guardrails** section
3. Assign guardrails to filter retrieved content
4. Note: Re-indexing is required for changes to take effect

---

## Guardrail Configuration Options

### Source Selection

**Input Guardrails**: Filter incoming content
- User messages in conversations
- Workflow input parameters
- Query text for knowledge bases

**Output Guardrails**: Filter generated content
- Assistant responses
- Workflow output results
- Retrieved documents from knowledge bases

**Both**: Apply guardrail to both input and output

**Best Practice**: Use Input for user protection, Output for compliance, Both for maximum safety.

### Mode Selection

**All Mode** (Permissive):
- Returns full analysis including allowed and blocked content
- Use for general-purpose applications
- Provides detailed filtering information

**Filtered Mode** (Restrictive):
- Returns only blocked content and reasons
- Use for high-security applications
- More thorough filtering

---

## Guardrail Assignment Popup

The Assignment popup is the central place to manage all guardrail assignments:

### Opening the Assignment Popup

1. Go to **Settings** → **AWS Integration** → **Guardrails**
2. Click on an integration to view installed guardrails
3. For an installed guardrail, click **Assign**

### Assignment Popup Structure

The popup contains three tabs:
- **Assistants**: Assign guardrail to assistants
- **Workflows**: Assign guardrail to workflows
- **Data Sources**: Assign guardrail to knowledge bases

### Each Tab Shows:

**Project-Level Assignment Toggle**:
- Switch to enable/disable project-wide application
- When enabled, applies to all entities of that type
- Configuration settings for project-level assignment (Source and Mode)

**Entity-Specific Assignments**:
- Dropdown to select individual entities
- Each selected entity can have its own Source and Mode configuration
- Remove button (trash icon) to delete assignments
- Settings panel for each assignment showing:
  - Source dropdown (Input, Output, Both)
  - Mode dropdown (All, Filtered)

### Making Assignments

1. **Project-Wide**: Toggle the switch at the top and configure settings
2. **Specific Entities**: 
   - Select entities from the dropdown
   - Configure Source and Mode for each
   - Click the settings panel to expand configuration options
3. Click **Assign** to save all changes

---

## Viewing Guardrail Assignments

### From the Entity Details View

Each entity shows its guardrail assignments in two sections:

**Global Assignments** (Project/Other Entity):
- Guardrails inherited from project-level configuration
- Shows guardrail name, source, mode, and entity it's assigned from
- Read-only from the entity view

**Entity Assignments**:
- Guardrails assigned specifically to this entity
- Shows guardrail name, source, and mode
- Can be edited from this view

### From the Guardrail Details View

When viewing an installed guardrail:
- Shows which entities are using this guardrail
- Displays assignment configuration for each
- Click **Assign** to modify assignments

---

## Managing Guardrail Assignments

### View All Assignments

See where a guardrail is applied:

1. Go to **Settings** → **AWS Integration** → **Guardrails**
2. Select an integration
3. Click **More Info** on an installed guardrail
4. The details view shows the guardrail configuration including topics and content filters

### Modify Assignments

To change guardrail assignments:

1. Click the **Assign** button on the installed guardrail
2. In the Assignment popup:
   - Toggle project-wide switches on/off
   - Add or remove entity-specific assignments
   - Update Source and Mode configurations
3. Click **Assign** to save changes

### Remove Assignments

**Remove Project-Wide Assignment**:
1. Open the Assignment popup
2. Toggle off the project-wide switch for the entity type
3. Click **Assign** to save

**Remove Entity-Specific Assignment**:
1. Open the Assignment popup
2. Navigate to the appropriate tab
3. Click the trash icon next to the entity assignment
4. Click **Assign** to save

### Uninstall Guardrail

To completely remove a guardrail from Codemie:

1. From the guardrail details view, click **Uninstall**
2. Confirm the uninstallation
3. All assignments will be removed
4. The guardrail can be reinstalled later if needed

---

## Assignment Priority

When multiple guardrails are assigned to an entity:

### Evaluation Order

1. **Entity-Level Guardrails**: Applied first
2. **Project-Level Guardrails**: Applied as default baseline

### Override Behavior

- Entity-specific assignments take precedence
- Project-level assignments provide baseline protection
- Both can coexist and layer protection
- The entity details view shows both types separately

### Best Practice

- Use project-level for baseline protection across all entities
- Use entity-level for enhanced protection on specific high-risk entities
- Document why specific entities have additional guardrails

---

## Testing Guardrail Assignments

### Test Before Deployment

Always test guardrail assignments:

1. **For Assistants**:
   - Start a test conversation
   - Try various inputs that should be filtered
   - Verify Output filtering on responses
   - Check for false positives

2. **For Workflows**:
   - Execute with test inputs
   - Verify filtering at each step
   - Check output results

3. **For Knowledge Bases**:
   - Query with terms that should be filtered
   - Verify sensitive information is blocked
   - Check retrieval accuracy
   - Remember: Re-indexing may be required

---

## Common Configuration Patterns

### Pattern 1: Baseline Protection

**Setup**:
- Project-level guardrail with content filters
- Source: Both
- Mode: All
- Applied to all entity types

**Use Case**: General workplace safety across all entities

---

### Pattern 2: High-Security Assistants

**Setup**:
- Project-level: Basic content filtering
- Entity-level: Strict guardrail with PII detection
- Source: Both
- Mode: Filtered

**Use Case**: Customer service assistants handling sensitive data

---

### Pattern 3: Knowledge Base Protection

**Setup**:
- Entity-level on knowledge base
- Source: Output
- Mode: Filtered
- Filters: PII, financial data

**Use Case**: Prevent sensitive document leakage

---

### Pattern 4: Development vs Production

**Setup**:
- Dev project: Lenient guardrails (Mode: All)
- Prod project: Strict guardrails (Mode: Filtered)

**Use Case**: Test without restrictions, deploy with protection

---

## Troubleshooting

### "Guardrail blocking legitimate content"

**Solutions**:
1. Review filter strength in AWS (reduce from HIGH to MEDIUM)
2. Check for overly broad topic filters
3. Switch from Filtered to All mode
4. Add exception rules in AWS guardrail configuration
5. Create a new version in AWS and install it in Codemie

### "Guardrail not blocking violations"

**Solutions**:
1. Verify guardrail is assigned with correct source (Input/Output)
2. Check mode is appropriate (Filtered for strict filtering)
3. Review AWS guardrail policy strength
4. Test with explicit violation examples
5. Ensure the guardrail version is PREPARED and installed

### "Cannot assign guardrail"

**Causes**:
- Guardrail was deleted in AWS
- Guardrail is not installed in Codemie
- No permission to modify entity

**Solutions**:
1. Check guardrail still exists in AWS
2. Verify the guardrail is installed (has an AI Run ID)
3. Verify you have permission to modify the entity
4. Refresh the page and try again

### "Assignment not taking effect"

**Solutions**:
1. Check assignment source matches usage (Input vs Output)
2. For knowledge bases, verify re-indexing has completed
3. Review guardrail version (may need to install newer version)
4. Check AWS guardrail status (must be READY)
5. Verify the guardrail hasn't been uninstalled

### "Cannot see assignment options"

**Solutions**:
1. Ensure the guardrail is installed (not just visible in AWS)
2. Check that you're viewing an installed version (shows AI Run ID)
3. Verify you have access to the project
4. Refresh the page to update available options

---

## Best Practices Summary

1. **Start with Project-Level**: Apply baseline guardrails project-wide using the Assignment popup

2. **Layer Protection**: Use both project and entity-level for critical entities

3. **Test Thoroughly**: Always test with representative content before deployment

4. **Document Exceptions**: Keep notes on why specific entities have custom guardrails

5. **Use the Assignment Popup**: Centralized view makes it easier to manage all assignments

6. **Version Control**: Track which guardrail versions are installed and assigned

7. **Monitor Impact**: Check that guardrails aren't too restrictive in practice

8. **Balance Safety and Usability**: Avoid overly restrictive configurations

9. **Staged Rollout**: Test new guardrail configurations with a subset of entities first

10. **Understand Mode Differences**: Choose between All and Filtered based on your needs

11. **Re-index When Needed**: Remember that knowledge base guardrails require re-indexing

12. **Keep AWS Synced**: Changes in AWS guardrail policies are reflected automatically

---

## Important Notes

### For Knowledge Bases

- When assigning guardrails to knowledge bases, re-indexing is required for existing data sources
- New guardrails automatically apply to newly created data sources when project-wide assignment is enabled
- This is noted in the Assignment popup with a helpful message

### Assignment View

- Entity details pages show both "Global Assignments" and "Entity Assignments"
- Global assignments come from project-level or other entities
- Entity assignments are specific to that entity
- Both types are displayed separately for clarity

### Source Options

Currently, only **Input** source is fully supported. Output and Both options may be visible but limited in functionality.

---

## Next Steps

- Install AWS Agents as Assistants
- Install AWS Knowledge Bases as Data Sources
- Install AWS Guardrails
- Install AWS Flows as Workflows