# Release Process for Agent Template

## Release Workflow

We use GitHub Actions for automated Docker image releases to GitHub Container Registry (GHCR).

### 1. Prepare Release

Create a release branch and bump version:
```bash
git checkout -b release/X.Y.Z
# Update version in any relevant files (e.g., README.md examples)
git commit -am "chore: bump version to X.Y.Z"
git push -u origin release/X.Y.Z
```

### 2. Test Build

**Manual test via GitHub Actions** (from Actions tab):
1. Go to Actions → "Build and Release to GHCR"
2. Click "Run workflow"
3. Select branch: `release/X.Y.Z`
4. Version: `X.Y.Z` (without 'v' prefix)
5. Push: `false` (dry run first)
6. Verify build succeeds

### 3. Create Pull Request

Create PR from `release/X.Y.Z` to `main`:
- Wait for CI checks to pass
- Review Dockerfile changes if any
- Verify license compliance is working

### 4. Test Release

**Push test image** (from Actions tab):
1. Run workflow again on `release/X.Y.Z`
2. Version: `X.Y.Z`
3. Push: `true`
4. This creates `ghcr.io/agentsystems/agent-template:X.Y.Z`

**Test the image**:
```bash
# Pull and test
docker pull ghcr.io/agentsystems/agent-template:X.Y.Z

# Test as base image
cat > test.Dockerfile << EOF
FROM ghcr.io/agentsystems/agent-template:X.Y.Z
COPY test_agent.py /app/
CMD ["python", "/app/test_agent.py"]
EOF

# Build test agent
docker build -f test.Dockerfile -t test-agent .
docker run --rm test-agent

# Test standalone
docker run -d \
  --name test-template \
  -p 8000:8000 \
  ghcr.io/agentsystems/agent-template:X.Y.Z

# Verify it's running
curl http://localhost:8000/health
docker logs test-template
docker stop test-template && docker rm test-template
```

### 5. Final Release

If tests pass:

1. **Merge the PR** to main

2. **Create and push version tag**:
   ```bash
   git checkout main
   git pull origin main
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   git push origin vX.Y.Z
   ```

3. **Automatic release** happens on tag push:
   - Creates `ghcr.io/agentsystems/agent-template:X.Y.Z`
   - Updates `ghcr.io/agentsystems/agent-template:latest`
   - Creates GitHub Release with notes

### 6. Verify Production Release

```bash
# Verify latest tag updated
docker pull ghcr.io/agentsystems/agent-template:latest
docker inspect ghcr.io/agentsystems/agent-template:latest | grep -i version

# Verify specific version
docker pull ghcr.io/agentsystems/agent-template:X.Y.Z
```

## Version Numbering

Follow semantic versioning:
- **MAJOR.MINOR.PATCH** (e.g., 0.1.0)
- **MAJOR**: Breaking changes to template structure
- **MINOR**: New features, dependencies, backward compatible
- **PATCH**: Bug fixes, dependency updates, backward compatible

## Quick Release (for maintainers)

For a quick patch release:
```bash
# On main branch
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
# Workflow automatically builds and pushes to GHCR
```

## Template Updates

When updating the template:
1. Test with a real agent implementation
2. Ensure requirements.txt is up to date
3. Verify Dockerfile best practices
4. Check license compliance automation works

## Notes

- The `latest` tag only updates on stable releases (version tags)
- The `main` tag always reflects the latest commit on main branch
- All images include full license compliance in `/app/licenses/`
- Multi-platform images support both linux/amd64 and linux/arm64
- This template is meant to be extended via FROM in other Dockerfiles
